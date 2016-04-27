if [[ $(uname -s) == Darwin ]]; then
    if [[ -f ~/Library/Python/2.7/lib/python/site-packages/powerline/bindings/zsh/powerline.zsh ]]; then
        . ~/Library/Python/2.7/lib/python/site-packages/powerline/bindings/zsh/powerline.zsh
    fi
else
    PATH="$HOME/.local/bin:$PATH"
    if [[ -f ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh ]]; then
        . ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
    fi
fi
