if [[ $(uname -s) == Darwin ]]; then
    if [[ -x ~/Library/Python/2.7/bin/powerline-daemon ]]; then
        ~/Library/Python/2.7/bin/powerline-daemon -q
        POWERLINE_BASH_CONTINUATION=1
        POWERLINE_BASH_SELECT=1
        . ~/Library/Python/2.7/lib/python/site-packages/powerline/bindings/bash/powerline.sh
    fi
else
    if [[ -x ~/.local/bin/powerline-daemon ]]; then
        ~/.local/bin/powerline-daemon -q
        POWERLINE_BASH_CONTINUATION=1
        POWERLINE_BASH_SELECT=1
        PATH="$HOME/.local/bin:$PATH"
        . ~/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
    fi
fi
