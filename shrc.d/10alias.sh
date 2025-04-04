#!/bin/bash

[[ $OSTYPE =~ darwin* ]] && Apple=true
[[ $OSTYPE =~ linux* ]] && Linux=true

# -----------------------------------------------------------------------------
# Handy aliases to view PATH and LD_LIBRARY_PATH

alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

function yesno {
    local QUESTION="$1"
    local ANSWER=""
    while true; do
        if [[ -n $ZSH_NAME ]]; then
            read -r -q "ANSWER?$QUESTION [y/n]"
        else
            read -r -n 1 -p "$QUESTION [y/n] " ANSWER
            echo
        fi
        case $ANSWER in
            [yY]*) return 0;;
            [nN]*) return 1;;
        esac
    done
}

function editpath {
    local temp_file
    temp_file="$(mktemp)"
    # shellcheck disable=SC2064
    trap "{ rm -f -- '$temp_file'; }" EXIT
    echo "Created temp file: $temp_file"
    path > "$temp_file"
    vim "$temp_file"
    local new_path
    new_path=$(tr '\n' ':' < "$temp_file" | sed 's/:$//')
    echo "Diff:"
    diff -y --color=auto <(echo -e "${PATH//:/\\n}") <(echo -e "${new_path//:/\\n}")
    echo
    yesno "Did you want to change your path?" && export PATH="$new_path"
}

# -----------------------------------------------------------------------------
# du and df
alias du='du -kh'
[[ $Linux == true ]] && alias df='df -Th'
[[ $Apple == true ]] && alias df='df -h'

# -----------------------------------------------------------------------------
# The 'ls' family
alias ll='ls -l'
if [[ $Linux == true ]]; then 
    if [[ -x /usr/bin/dircolors ]]; then
        eval "$(dircolors -b)"
        alias ls='ls -F --color=auto'
    fi
else
    alias ls='ls -F'
fi
[[ $Apple == true ]] && alias ls='ls -FG'
alias lh='ls -lh'
alias la='ls -Al'               # show hidden files
alias lx='ls -lXB'              # sort by extension
alias lk='ls -lSr'              # sort by size, biggest last
alias lc='ls -ltcr'             # sort by and show change time, most recent last
alias lu='ls -ltur'             # sort by and show access time, most recent last
alias lt='ls -ltr'              # sort by date, most recent last
alias lm='ls -al | more'        # pipe through 'more'
alias lr='ls -lR'               # recursive ls
alias tree='tree -Csu'          # nice alternative to 'recursive ls'
alias l='ls -CF'

command -v kubectl &>/dev/null && alias k=kubectl

# -----------------------------------------------------------------------------
# enable color support for grep if linux supports it or on Apple
if [[ -x /usr/bin/dircolors || $Apple == true ]]; then
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias json="python -m json.tool"
alias xml="xmllint --format -"
alias html="tidy -i --indent-spaces 4"

if [[ $Linux == true ]]; then
    alias chown='chown --preserve-root'
    alias chmod='chmod --preserve-root'
    alias chgrp='chgrp --preserve-root'
    alias rm='rm --preserve-root'
fi


alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock docker.io/wagoodman/dive"
