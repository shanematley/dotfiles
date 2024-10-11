#!/usr/bin/env bash

set -euo pipefail

source "${BASH_SOURCE%/*}"/lib.sh

update_coc_diagnostic_extensions() {
    local coc_settings_location=$1
    local temp_location="${coc_settings_location}.tmp"

    command -v jq &> /dev/null || { echo "Cannot update coc settings as jq is not installed"; return 1; }

    if [[ ! -r "$coc_settings_location" ]]; then
        mkdir -p "$(dirname "$coc_settings_location")"
        echo "{}" > "$coc_settings_location"
    fi

    trap 'rm -f - "${temp_location}"' RETURN

    if ! jq '.["diagnostic-languageserver.filetypes"] += {"sh": "shellcheck", "python": "flake8"}' "$coc_settings_location" > "$temp_location"; then
        softfail "Failed to run jq over $coc_settings_location. Unable to update coc diagnostic settings"
        return
    fi

    if diff -q "$temp_location" "$coc_settings_location" >/dev/null; then
        info "coc diagnostic settings ok in $coc_settings_location"
    else
        check "Updated coc diagnostic settings in $coc_settings_location" mv "$temp_location" "$coc_settings_location"
    fi
}

section "Verifying VIM coc diagnostic configuration"

update_coc_diagnostic_extensions "${HOME}/.config/nvim/coc-settings.json"
update_coc_diagnostic_extensions "${HOME}/.vim/coc-settings.json"
