#!/usr/bin/env bash

DOTFILES_PATH="$(readlink -f -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[*]}")")"/..)"
source "$DOTFILES_PATH/lib.sh"

k9s_config_path() {
    if osis Darwin; then
        echo "${XDG_CONFIG_HOME:-$HOME/Library/Application Support}/k9s"
    else
        echo "${XDG_CONFIG_HOME:-$HOME/.config}/k9s"
    fi
}

ensure_k9s_skins_installed() {
    local k9s_config_dir
    k9s_config_dir="$(k9s_config_path)"
    ensure_dir "$k9s_config_dir/skins"
    for f in "$DOTFILES_PATH/k9s/skins/"*; do
        ensure_link "$f" "$k9s_config_dir/skins/$(basename "$f")"
    done
}

set_k9s_colortheme() {
    local theme="$1"
    local k9s_config_dir
    k9s_config_dir="$(k9s_config_path)"

    update_yaml "$k9s_config_dir/config.yaml" '.k9s.ui.skin = "'"$theme"'"' || return
}

if [[ "$1" == install ]]; then
    section "Setting up k9s themes"

    ensure_k9s_skins_installed
else
    set_k9s_colortheme "$1"
fi
