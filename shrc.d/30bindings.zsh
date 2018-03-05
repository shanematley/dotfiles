bindkey -e
bindkey '^]'   'vi-find-next-char'
bindkey '\M^]' 'vi-find-prev-char'
bindkey '^U'  'backward-kill-line'

# Enable Ctrl-x-e to edit command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# Bash style word selection (e.g. CTRL-W and M-left)
autoload -U select-word-style
select-word-style bash

# context help.
autoload -Uz run-help
autoload -Uz run-help-git
bindkey "^[OP" run-help # F1 key

# To determine what keys these actually are:
# echo '<Ctrl-V><key>' | od -c
# Where <Ctrl-V> is actually Ctrl-V and <key> is the key to test.
if [[ $(uname) = Darwin ]]; then
    bindkey '^[[3~' delete-char
    bindkey '^[[1~' beginning-of-line
    bindkey '^[[4~' end-of-line
fi
