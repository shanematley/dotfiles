function termtitle() {
    if [[ -z $TMUX ]]; then
        echo -ne "\033]0;$@\007"
    else
        echo -ne "\033Ptmux;\033\033]0;$@\007\033\\"
    fi
}

function panetitle() {
    echo -en "\033k$@\033\\"
}
