if [[ $(uname -s) == Darwin ]]; then
    if [[ -f ~/bin/powerline.zsh ]]; then
        source ~/bin/powerline.zsh
    fi
else
    PATH="$HOME/.local/bin:$PATH"
    if [[ -f ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh ]]; then
        . ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
    fi
fi
