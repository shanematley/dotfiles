#!/bin/zsh

autoload -U colors && colors
# For additional information on the options available, refer to
# section EXPANSION OF PROMPT SEQUENCES of zshmisc(1)
read -r -d '' PROMPT <<EOF
$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
%{$PR_MAGENTA%}► %{$PR_GREEN%}%n@%m%{$reset_color%}%{$PR_MAGENTA%}:\
%{$PR_CYAN%}%~%{$reset_color%}\
%{%(!.$PR_RED.$reset_color)%} %{$PR_MAGENTA%}[%D{%Y-%m-%d %H:%M%Z}]
%#%{$reset_color%}
EOF
PROMPT="${PROMPT} "

export PROMPT
