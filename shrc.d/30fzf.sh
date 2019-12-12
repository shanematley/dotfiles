
function rgf() {
    rg --files-with-matches "$1"|fzf --preview 'grep -C 5 --color=always '"$1"'{}'
}

if command -v highlight >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
fi

export FZF_CTRL_R_OPTS="--sort --preview 'echo {}' --preview-window down:5:hidden:wrap --bind '?:toggle-preview'"
