#!/usr/bin/env bash
set -euo pipefail

ORIG_ROOT="$1"
ALBUM_NAME="$2"
EXPORTED="$3"

FD="/opt/homebrew/bin/fd"
EXIFTOOL="/opt/homebrew/bin/exiftool"
PYTHON="/opt/homebrew/bin/python3"

TARGET_TZ="${TARGET_TZ:-Australia/Sydney}"
ORIG_DIR="${ORIG_ROOT%/}/$ALBUM_NAME"

warn() { echo "WARN: $*" >&2; }

[[ -f "$EXPORTED" ]] || { warn "exported file not found: $EXPORTED"; exit 10; }
[[ -d "$ORIG_DIR" ]] || { warn "original album folder not found: $ORIG_DIR (skipping $(basename "$EXPORTED"))"; exit 20; }

fname="$(basename "$EXPORTED")"
base="${fname%.*}"

# Find original in ORIG_DIR by basename + allowed extensions
matches=()
while IFS= read -r line; do
  [[ -n "$line" ]] && matches+=("$line")
done < <(
  "$FD" -i -t f "^${base}\.(mp4|mov|avi|mts|m2ts|mpg|mpeg|3gp)$" "$ORIG_DIR"
)

if [[ ${#matches[@]} -eq 0 ]]; then
  warn "no original match for $fname in $ORIG_DIR (skipping)"
  exit 21
fi

if [[ ${#matches[@]} -gt 1 ]]; then
  warn "duplicate originals for $fname in $ORIG_DIR (skipping). Matches:"
  printf '  - %s\n' "${matches[@]}" >&2
  exit 22
fi

orig="${matches[0]}"

# Extract candidate timestamps from the original
json_file="$(mktemp -t exifjson.XXXXXX)"
trap 'rm -f "$json_file"' EXIT

"$EXIFTOOL" -j -a -G1 -s \
  -api QuickTimeUTC=1 \
  -DateTimeOriginal \
  -CreateDate -ModifyDate \
  -MediaCreateDate -TrackCreateDate \
  -QuickTime:CreateDate -QuickTime:ModifyDate -QuickTime:MediaCreateDate -QuickTime:TrackCreateDate \
  -XMP:CreateDate -XMP:ModifyDate \
  -FileModifyDate \
  "$orig" > "$json_file"

# Python prints:
#   DT_LOCAL=YYYY:MM:DD HH:MM:SS
#   DT_KEYS=YYYY:MM:DD HH:MM:SS±HH:MM   (may be blank)
py_kv="$(
  TARGET_TZ="$TARGET_TZ" "$PYTHON" - "$json_file" <<'PY'
import json, sys, re, os
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo

json_path = sys.argv[1]
with open(json_path, "r", encoding="utf-8") as f:
    data = json.load(f)

tags = data[0] if data else {}
TARGET = ZoneInfo(os.environ.get("TARGET_TZ", "Australia/Sydney"))

def first(*keys):
    for k in keys:
        v = tags.get(k)
        if v:
            return v
    return None

candidates = [
    first("DateTimeOriginal", "EXIF:DateTimeOriginal", "RIFF:DateTimeOriginal"),
    first("XMP:CreateDate"),
    first("QuickTime:CreateDate"),
    first("QuickTime:MediaCreateDate", "MediaCreateDate"),
    first("QuickTime:TrackCreateDate", "TrackCreateDate"),
    first("CreateDate"),
    first("XMP:ModifyDate"),
    first("QuickTime:ModifyDate"),
    first("ModifyDate"),
    first("FileModifyDate", "System:FileModifyDate"),
]

pat = re.compile(r"^(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})([+-]\d{2}:\d{2})?$")

def parse_any(s: str):
    s = s.strip()
    m = pat.match(s)
    if not m:
        return None
    y,mo,d,hh,mm,ss,off = m.groups()
    dt = datetime(int(y),int(mo),int(d),int(hh),int(mm),int(ss))
    if off:
        sign = 1 if off[0] == "+" else -1
        oh, om = map(int, off[1:].split(":"))
        tz = timezone(timedelta(seconds=sign * (oh*3600 + om*60)))
        # convert into TARGET, return naive local time in TARGET
        return dt.replace(tzinfo=tz).astimezone(TARGET).replace(tzinfo=None)
    # no offset => treat as floating local time
    return dt

dt = None
for c in candidates:
    if c:
        dt = parse_any(c)
        if dt:
            break

dt_local = dt.strftime("%Y:%m:%d %H:%M:%S") if dt else ""

dt_keys = ""
if dt:
    aware = dt.replace(tzinfo=TARGET)
    off = aware.utcoffset()
    if off is not None:
        total_minutes = int(off.total_seconds() // 60)
        sign = "+" if total_minutes >= 0 else "-"
        total_minutes = abs(total_minutes)
        hh, mm = divmod(total_minutes, 60)
        dt_keys = dt.strftime("%Y:%m:%d %H:%M:%S") + f"{sign}{hh:02d}:{mm:02d}"

print(f"DT_LOCAL={dt_local}")
print(f"DT_KEYS={dt_keys}")
PY
)"

dt_local="$(printf '%s\n' "$py_kv" | sed -n 's/^DT_LOCAL=//p' | head -n 1)"
dt_keys="$(printf '%s\n' "$py_kv" | sed -n 's/^DT_KEYS=//p' | head -n 1)"

if [[ -z "$dt_local" ]]; then
  # last resort: original filesystem mtime (local)
  dt_local="$(stat -f '%Sm' -t '%Y:%m:%d %H:%M:%S' "$orig")"
  dt_keys=""  # unknown offset in this fallback
fi

# Build exiftool args safely (no tricky quoting/expansions)
args=(-overwrite_original)

if [[ -n "$dt_keys" ]]; then
  args+=("-Keys:CreationDate=$dt_keys")
  args+=("-Keys:ModifyDate=$dt_keys")
fi

args+=("-QuickTime:CreateDate=$dt_local")
args+=("-QuickTime:ModifyDate=$dt_local")
args+=("-TrackCreateDate=$dt_local")
args+=("-TrackModifyDate=$dt_local")
args+=("-MediaCreateDate=$dt_local")
args+=("-MediaModifyDate=$dt_local")

"$EXIFTOOL" "${args[@]}" "$EXPORTED" >/dev/null

echo "OK: $(basename "$EXPORTED") ← $(basename "$orig") @ $dt_local (Keys=${dt_keys:-n/a}, TZ=$TARGET_TZ)"
