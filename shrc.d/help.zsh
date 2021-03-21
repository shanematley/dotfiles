# Finding help for builtin ZSH functions. E.g. can do the following:
#   run-help bindkey
[[ -n $(alias run-help) ]] && unalias run-help
autoload -Uz run-help
