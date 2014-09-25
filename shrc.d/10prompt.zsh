#!/bin/zsh

# For additional information on the options available, refer to
# section EXPANSION OF PROMPT SEQUENCES of zshmisc(1)
read -r -d '' PROMPT <<EOF
$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
[\
%{$PR_GREEN%}%n@%m%{$reset_color%}:\
%{$PR_CYAN%}%~%{$reset_color%}\
:%D{%Y%m%d %H%M%Z}]%{%(!.$PR_RED.$reset_color)%}%#
EOF
PROMPT="${PROMPT} "

export PROMPT
