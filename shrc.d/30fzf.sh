
if command -v highlight >/dev/null 2>&1; then
    fif() {
        if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
        rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
    }

    export FZF_CTRL_T_OPTS="
        --multi
        --preview '(bat -n --color=always {} || cat {} | tree -C {}) 2> /dev/null | head -200'
        --bind 'alt-enter:become(vim {+} < /dev/tty > /dev/tty),ctrl-y:execute-silent(echo -n {+} | pbcopy)+abort,ctrl-/:change-preview-window(50%|hidden|)'
        --color header:italic
        --header 'Press CTRL-Y to copy file paths into clipboard. ALT-Enter to open in vim. Ctrl-/ (Ctrl-_) to toggle preview'"
fi

# Use tmux by default. This is ignored when not in tmux
export FZF_TMUX_OPTS='-p80%,60%'
export FZF_DEFAULT_OPTS_BASE="--height=40% --layout=reverse --info=inline --border"

fzf_set_dark_color_scheme() {
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS_BASE} --color 'fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899'"
}

fzf_set_light_color_scheme() {
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS_BASE}
        --color=fg:#4d4d4c,bg:#eeeeee,hl:#d7005f
        --color=fg+:#4d4d4c,bg+:#e8e8e8,hl+:#d7005f
        --color=info:#4271ae,prompt:#8959a8,pointer:#d7005f
        --color=marker:#4271ae,spinner:#4271ae,header:#4271ae"
}

# Note: the fzf color scheme is set in 99colorscheme.sh

export FZF_CTRL_R_OPTS="
    --sort
    --preview 'echo {}' --preview-window down:5:wrap --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort,ctrl-/:change-preview-window(50%|hidden|)'
    --header 'Press CTRL-Y to copy commands into clipboard. Ctrl-/ (Ctrl-_) to toggle preview 50%'
    --color header:italic"

# Use `tree` to show the entries of the directory
export FZF_ALT_C_OPTS="
    --preview 'tree -C {} | head -200'
    --header 'Press CTRL-Y to copy commands into clipboard. Ctrl-/ (Ctrl-_) to toggle preview'
    --bind='ctrl-y:execute-silent(echo -n {+} | pbcopy)+abort,ctrl-/:change-preview-window(hidden|)'"

# From https://github.com/junegunn/fzf#settings
#
# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}

if command -v kubectl >/dev/null 2>&1; then
    pods() {
    FZF_DEFAULT_COMMAND="kubectl get pods --all-namespaces" \
        fzf --info=inline --layout=reverse --header-lines=1 \
            --prompt "$(kubectl config current-context | sed 's/-context$//')> " \
            --header $'╱ Enter (kubectl exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱\n\n' \
            --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
            --bind 'enter:execute:kubectl exec -it --namespace {1} {2} -- bash > /dev/tty' \
            --bind 'ctrl-o:execute:${EDITOR:-vim} <(kubectl logs --all-containers --namespace {1} {2}) > /dev/tty' \
            --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
            --preview-window up:follow \
            --preview 'kubectl logs --follow --all-containers --tail=10000 --namespace {1} {2}' "$@"
    }
fi

fzf_diff() {
        preview="git diff $@ --color=always -- {-1}"
        git diff $@ --name-only | fzf -m --ansi --preview $preview --preview-window wrap
}

fzf_diff() {
        preview="git diff --name-only --diff-filter=d --relative -- {-1} | \
            xargs bat --diff --color=always --style=numbers,changes {-1}"
        git diff $@ --name-only | fzf -m --ansi --preview $preview
}
