function add_to_path() {
    if [[ -d $1 ]]; then
        if [[ -n $PATH ]]; then
            PATH="$1:$PATH"
        else
            PATH="$1"
        fi
    fi
}
function add_to_man_path() {
    if [[ -d $1 ]]; then
        if [[ -n $MANPATH ]]; then
            MANPATH="$MANPATH:$1"
        else
            MANPATH=":$1"
        fi
    fi
}

add_to_path "$HOME/Library/Python/2.7/bin"
add_to_path "$HOME/bin"

add_to_man_path "$HOME/man"

export PATH
export MANPATH

