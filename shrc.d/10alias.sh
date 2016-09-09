#!/bin/bash

[[ $OSTYPE =~ darwin* ]] && Apple=true
[[ $OSTYPE =~ linux* ]] && Linux=true

alias cd-="cd $(pwd)"

# -----------------------------------------------------------------------------
# Handy aliases to view PATH and LD_LIBRARY_PATH

alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

function make_unique_temp() {
    if [[ $Apple == true ]]; then
        mktemp -t "temp"
    else
        mktemp
    fi
}
function yesno {
    local QUESTION="$1"
    local ANSWER=""
    while true; do
        if [[ -n $ZSH_NAME ]]; then
            read -q "ANSWER?$QUESTION [y/n]"
        else
            read -n 1 -p "$QUESTION [y/n] " ANSWER
            echo
        fi
        case $ANSWER in
            [yY]*) return 0;;
            [nN]*) return 1;;
        esac
    done
}
function editpath {
    TEMP_FILE=$(make_unique_temp)
    echo "Created temp file: $TEMP_FILE"
    if [[ -n $ZSH_NAME ]]; then
        path >! "$TEMP_FILE"
    else
        path > "$TEMP_FILE"
    fi
    vim "$TEMP_FILE"
    NEW_PATH=$(cat "$TEMP_FILE" | tr '\n' ':' | sed 's/:$//')
    echo "$NEW_PATH"
    echo "    Original: $PATH"
    echo "    New:      $NEW_PATH"
    echo
    echo "Diff:"
    diff <(echo -e "${PATH//:/\\n}") <(echo -e "${NEW_PATH//:/\\n}")
    echo
    yesno "Did you want to change your path?" && export PATH="$NEW_PATH"
    rm "$TEMP_FILE"
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
        eval "`dircolors -b`"
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

hash ack-grep 2>/dev/null && alias ack=ack-grep

if [[ $Apple == true ]]; then
    memcpu() { echo "*** Top 10 cpu eating processes ***"; ps aux | sort -nr -k 3 | head -10;
        echo "*** Top 10 memory eating processes ***"; ps aux | sort -nr -k 4 | head -n10;
    }
else
    memcpu() { echo "*** Top 10 cpu eating processes ***"; ps auxf | sort -nr -k 3 | head -10;
        echo "*** Top 10 memory eating processes ***"; ps auxf | sort -nr -k 4 | head -n10;
    }
fi

if [[ $Linux == true ]]; then
    alias chown='chown --preserve-root'
    alias chmod='chmod --preserve-root'
    alias chgrp='chgrp --preserve-root'
    alias rm='rm --preserve-root'
fi

