#!/bin/zsh

# For additional information on the options available, refer to
# section EXPANSION OF PROMPT SEQUENCES of zshmisc(1)
eval PR_NO_COLOUR='${terminfo[sgr0]%}'
read -r -d '' PROMPT <<EOF
$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
[\
%{$PR_GREEN%}%n@%m%{$PR_NO_COLOUR%}:\
%{$PR_CYAN%}%~%{$PR_NO_COLOUR%}\
]%{%(!.$PR_RED.$PR_NO_COLOUR)%}%#
EOF
PROMPT="${PROMPT} "

export PROMPT
