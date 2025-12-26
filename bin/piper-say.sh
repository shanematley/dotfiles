#!/usr/bin/env bash
# Idea taken from https://www.thoughtasylum.com/2025/08/25/text-to-speech-on-macos-with-piper/?__readwiseLocation=

set -euo pipefail

# Voices are available from https://huggingface.co/rhasspy/piper-voices/tree/main
VOICES_DIR="$HOME/.config/piper-say/voices"
VOICE_MODEL="$VOICES_DIR/default"

download_default_voice() {
    mkdir -p "$VOICES_DIR"
    local DEFAULT_VOICE_URL='https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_GB/alba/medium/en_GB-alba-medium.onnx?download=true'
    local DEFAULT_VOICE_JSON_URL='https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_GB/alba/medium/en_GB-alba-medium.onnx.json?download=true'

    echo "No voice model available. Downloading from $DEFAULT_VOICE_URL"

    # Download into that directory and capture the local filename curl chose
    local FILENAME
    FILENAME="$(
        curl -fsSLJO --output-dir "$VOICES_DIR" -w '%{filename_effective}\n' "$DEFAULT_VOICE_URL"
    )"
    local JSON_FILENAME
    JSON_FILENAME="$(
        curl -fsSLJO --output-dir "$VOICES_DIR" -w '%{filename_effective}\n' "$DEFAULT_VOICE_JSON_URL"
    )"
    ln -s "$FILENAME" "$VOICE_MODEL"
    ln -s "$JSON_FILENAME" "$VOICE_MODEL.json"
    echo "Downloaded as: $FILENAME. Linked to $VOICE_MODEL"
}

if [[ ! -r "$VOICE_MODEL" ]]; then
    download_default_voice
fi

TEMP_WAV="$(mktemp /tmp/piper-XXXXXX.wav)"
trap 'rm -f "$TEMP_WAV"' EXIT

# Decide input source
if [[ $# -gt 0 ]]; then
  # Read from file argument
  INPUT_FILE="$1"
  if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: file not found: $INPUT_FILE" >&2
    exit 1
  fi

  uvx --python 3.13 --from piper-tts piper \
    --model "$VOICE_MODEL" \
    --input_file "$INPUT_FILE" \
    --output_file "$TEMP_WAV"

elif [[ -t 0 ]]; then
  # No stdin, no args → usage
  echo "Usage:"
  echo "  echo \"text\" | $0"
  echo "  $0 file.txt"
  exit 1

else
  # Read from stdin
  uvx --python 3.13 --from piper-tts piper \
    --model "$VOICE_MODEL" \
    --output_file "$TEMP_WAV"
fi

afplay "$TEMP_WAV"

