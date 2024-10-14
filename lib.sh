#!/usr/bin/env bash

set -Eeuo pipefail
trap "echo Error in: \${FUNCNAME:-top level}, line \${LINENO}" ERR

section()   { printf "\n## \033[0;35m%s\033[0m\n\n" "$1"; }
info()      { printf "\r  [ \033[00;34m.\033[0m ] %s\n" "$1"; }
user()      { printf "\r  [ \033[0;33m?\033[0m ] %s\n" "$1"; }
success()   { printf "\r\033[2K  [ \033[00;32m✔\033[0m ] %s\n" "$1"; }
fail()      { printf "\r\033[2K  [ \033[0;31m✘\033[0m ] %s\n" "$1"; echo ''; exit; }
softfail () { printf "\r\033[2K  [ \033[0;31m✘\033[0m ] %s\n" "$1"; }

source "${BASH_SOURCE%/*}/shrc.d/10osis.sh"

check() {
  local -r message=$1
  shift
  if "$@" >/dev/null 2>&1; then
    success "$message"
  else
    softfail "Failed: $message"
    return 1
  fi
}

# Ensure there is a softlink at $2 that refers to $1
#
# Pass in $3 if there is a previous link that needs to be removed.
# (Used for moving links from ~/bin to ~/.local/bin)
ensure_link() {
    local src="$1"
    local dest="$2"

    # This can be removed once things moved to ~/.local/bin
    if [[ -n ${3-} ]]; then
        local REMOVE_OLD
        REMOVE_OLD="$3"
        if [[ -L "$REMOVE_OLD" && $(readlink "$REMOVE_OLD") -ef "$src" ]]; then
            rm "$REMOVE_OLD" && success "Removed old link $REMOVE_OLD"
        fi
    fi

    [[ -e "$dest" && ! -L "$dest" ]]                   && { softfail "ERROR: $dest already exists. Skipping."; return 1; }
    [[ -L "$dest" && $(readlink "$dest") -ef "$src" ]] && { info "Skipping: $dest already points to correct file."; return 0; }
    if osis Darwin; then
        ln -shf "$src" "$dest"
    else
        ln -snf "$src" "$dest"
    fi

    if [[ -L $dest && $(readlink "$dest") -ef $src ]]; then
        success "Linked $dest -> $src"
    else
        softfail "Unable to link $dest to $src"
    fi
}

require_command() {
    if ! command -v "${2}" >/dev/null 2>&1; then
        softfail "Error: $1"
        return 1
    fi
}

ensure_dir() {
    local DEST="$1"
    [[ -d "$DEST" ]] && { info "Skipping: directory $DEST already exists."; return 0; }
    if mkdir -p "$DEST"; then
        success "Created directory $DEST"
    elif (( $# > 1 )) && [[ $2 == hardfail ]]; then
        fail "Unable to create directory $DEST"
    else
        softfail "Unable to create directory $DEST"
    fi
}

touch_if_missing() {
    if [[ ! -e $1 ]]; then
        check "Creating $1" touch "$1"
    fi
}

update_yaml() {
    local yaml_path="$1"
    local temp_location="$1.tmp"
    local update_command="$2"

    require_command "yq is required to update $yaml_path" yq || return

    touch_if_missing "$yaml_path"

    trap 'rm -f - "${temp_location}"; trap "" RETURN' RETURN

    if ! yq "$update_command" "$yaml_path" > "$temp_location"; then
        softfail "Failed to run yq update instruction $update_command. Unable to update $yaml_path."
        return 1
    fi

    if diff -q "$temp_location" "$yaml_path" >/dev/null; then
        info "$yaml_path configured correctly"
    else
        check "Updated $yaml_path" mv "$temp_location" "$yaml_path"
    fi
}

SCRIPTPATH=$(cd "$(dirname "$0")" || exit; pwd;)

export -f section info user success fail softfail check ensure_link ensure_dir touch_if_missing require_command update_yaml
export SCRIPTPATH MY_COLORTHEME
