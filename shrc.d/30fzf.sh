
if command -v highlight >/dev/null 2>&1; then
    fif() {
        if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
        rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
    }

    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
fi

export FZF_CTRL_R_OPTS="--sort --preview 'echo {}' --preview-window down:5:hidden:wrap --bind '?:toggle-preview'"

# Use `tree` to show the entries of the directory
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

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
