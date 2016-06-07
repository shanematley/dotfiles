bindkey -e
bindkey '^]'   'vi-find-next-char'
bindkey '\M^]' 'vi-find-prev-char'
bindkey '^U'  'backward-kill-line'

# To determine what keys these actually are:
# echo '<Ctrl-V><key>' | od -c
# Where <Ctrl-V> is actually Ctrl-V and <key> is the key to test.
if [[ $(uname) = Darwin ]]; then
    bindkey '^[[3~' delete-char
    bindkey '^[[1~' beginning-of-line
    bindkey '^[[4~' end-of-line
fi
