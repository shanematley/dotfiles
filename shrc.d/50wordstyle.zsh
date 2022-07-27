# map alt-z to selecting the select-word-style. E.g. alphanumerics vs whitespace vs command arguments.
autoload -U select-word-style
zle -N select-word-style
bindkey '\ez' select-word-style

# Use normal word-style for everything except transpose-words (I.e. alt-t)
select-word-style normal
zstyle :zle:transpose-words word-style shell
