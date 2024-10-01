function add_to_path() {
    if [[ -d $1 ]]; then
        # Only add to the path if not already present
        if ! echo "${PATH//:/\\n}"|grep -q "$1"; then
            if [[ -n $PATH ]]; then
                PATH="$1:$PATH"
            else
                PATH="$1"
            fi
        fi
    fi
}

add_to_path "$HOME/.local/bin"

export PATH
export MANPATH=":${XDG_DATA_HOME:-$HOME/.local/share}/man"
