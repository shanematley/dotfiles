# For Linux only
if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
    # Override with my own Ctrl-T
    bindkey '^t' fzf_my_ctrl_t
fi
