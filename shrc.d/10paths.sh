function add_to_path() {
    if [[ -d $1 ]]; then
        if [[ -n $PATH ]]; then
            PATH="$1:$PATH"
        else
            PATH="$1"
        fi
    fi
}

add_to_path "$HOME/Library/Python/2.7/bin"
add_to_path "$HOME/bin"

export PATH
export MANPATH

