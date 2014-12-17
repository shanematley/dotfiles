# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line

# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# Bash style word selection (e.g. CTRL-W and M-left)
autoload -U select-word-style
select-word-style bash
