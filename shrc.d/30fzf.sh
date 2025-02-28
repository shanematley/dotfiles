
if command -v bat >/dev/null 2>&1; then
    fif() {
        if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
        rg --files-with-matches --no-messages "$1" | \
            fzf --preview "bat -n --color=always {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}" --bind 'alt-enter:become(vim {+} < /dev/tty > /dev/tty)'
    }
fi

export FZF_CTRL_T_OPTS="
    --multi
    --preview '(bat -n --color=always {} || cat {} | tree -C {}) 2> /dev/null | head -200'
    --bind 'ctrl-y:execute-silent(echo -n {+} | yank.sh > /dev/tty)+abort'
    --bind 'ctrl-/:change-preview-window(hidden|)'
    --color header:italic
    --header 'C-Y: copy to clipboard. C-/ (C-_): toggle preview."$'\n\n'"'"

if command -v fd >/dev/null 2>&1; then
    # Use fd (https://github.com/sharkdp/fd) instead of the default find
    # command for listing path candidates.
    # - The first argument to the function ($1) is the base path to start traversal
    # - See the source code (completion.{bash,zsh}) for the details.
    _fzf_compgen_path() {
        fd --hidden --follow --exclude ".git"  . "$1"
    }

    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
        fd --type d --hidden --follow --exclude ".git" . "$1"
    }

    export FZF_CTRL_T_COMMAND="fd --hidden --follow --exclude .git --strip-cwd-prefix"
    export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS}
        --bind 'ctrl-w:reload(fd --hidden --follow --exclude .git --strip-cwd-prefix .)'
        --bind 'ctrl-e:reload(fd --hidden --follow --exclude .git --strip-cwd-prefix -I .)'
        --header 'C-Y: copy to clipboard. C-/ (C-_): toggle preview. C-w: no ignored. C-e: show ignored'"
fi

# Use tmux by default. This is ignored when not in tmux
export FZF_TMUX_OPTS='-p80%,60%'
export FZF_DEFAULT_OPTS_BASE="--height=40% --layout=reverse --info=inline --border"

export FZF_CTRL_R_OPTS="
    --sort
    --preview 'echo {}' --preview-window down:5:wrap
    --bind 'ctrl-y:execute-silent(echo -n {2..} | yank.sh > /dev/tty)+abort,ctrl-/:change-preview-window(50%|hidden|)'
    --header 'Press CTRL-Y to copy commands into clipboard. Ctrl-/ (Ctrl-_) to toggle preview 50%'
    --color header:italic"

# Use `tree` to show the entries of the directory
export FZF_ALT_C_OPTS="
    --preview 'tree -C {} | head -200'
    --header 'Press CTRL-Y to copy commands into clipboard. Ctrl-/ (Ctrl-_) to toggle preview'
    --bind='ctrl-y:execute-silent(echo -n {+} | yank.sh > /dev/tty)+abort,ctrl-/:change-preview-window(hidden|)'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

if command -v kubectl >/dev/null 2>&1; then
    pods() {
        FZF_DEFAULT_COMMAND="kubectl get pods --all-namespaces" \
            fzf-tmux --info=inline --layout=reverse --header-lines=1 \
                --prompt "$(kubectl config current-context | sed 's/-context$//')> " \
                --header $'╱ Enter (kubectl exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱\n\n' \
                --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
                --bind 'enter:execute:kubectl exec -it --namespace {1} {2} -- bash > /dev/tty' \
                --bind 'ctrl-o:execute:${EDITOR:-vim} <(kubectl logs --all-containers --namespace {1} {2}) > /dev/tty </dev/tty' \
                --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
                --preview-window up:follow \
                --preview 'kubectl logs --follow --all-containers --tail=10000 --namespace {1} {2}' "$@"
    }
fi

fzf_diff() {
    local preview="git diff $@ --color=always -- {-1}"
    if command -v bat >/dev/null 2>&1; then
        preview="git diff --name-only --diff-filter=d --relative -- {-1} | \
            xargs bat --diff --color=always --style=numbers,changes {-1}"
    fi
    git diff $@ --name-only | \
        fzf -m --ansi --preview $preview --bind 'alt-enter:become(vim {+} >/dev/tty </dev/tty)'
}

# Interactive jq queries using FZF
# Idea from: https://social.jvns.ca/@b0rk/110135929111161568
fzf_jq() {
    if command -v jq >/dev/null 2>&1; then
        echo '' | fzf --preview 'jq {q} < "'"$1"'"'
    else
        echo "jq is not installed. Please install jq first"
    fi
}
