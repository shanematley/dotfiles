# Must be run after 30fzf.sh

# Copied from fzf key-bindings.zsh
__fzf_my_cmd() {
  [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

__fzf_my_ctrl_t() {
    export __deployment_preview
    # the default FZF_CTRL_T_COMMAND is a direct copy from the fzf key-bindings.zsh
    local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
        -o -type f -print \
        -o -type d -print \
        -o -type l -print 2> /dev/null | cut -b3-"}"
    local result
    result=$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --scheme=path --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-}" $(__fzf_my_cmd) -m --expect=alt-enter,ctrl-y)
    result=("${(@f)result}")

    if [[ -z $result[1] ]]; then
        LBUFFER="${BUFFER}${(j: :)result[@]:1}"
    elif [[ $result[1] == alt-enter ]]; then
        BUFFER="${EDITOR:-vim} ${(j: :)result[@]:1}"
        zle accept-line
    elif [[ $result[1] == ctrl-y ]]; then
        echo -n "${result[@]:1}" | yank.sh
    fi
    zle reset-prompt
    return 0
}

zle -N fzf_my_ctrl_t __fzf_my_ctrl_t
bindkey '^t' fzf_my_ctrl_t


