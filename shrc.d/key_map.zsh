# Enable Ctrl-x-e to edit command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# Bash style word selection (e.g. CTRL-W and M-left)
autoload -U select-word-style
select-word-style bash

#if [[ $ZSH_VERSION[1] -ge 5 ]] ; then
    #bindkey -M isearch '^R' history-incremental-pattern-search-backward
    #bindkey -M isearch '^S' history-incremental-pattern-search-forward
#fi

#bindkey -M vicmd '^R' history-incremental-pattern-search-backward
#bindkey -M vicmd '^S' history-incremental-pattern-search-forward

# context help.
autoload -Uz run-help
autoload -Uz run-help-git
bindkey "^[OP" run-help # F1 key

