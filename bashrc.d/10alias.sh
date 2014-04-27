#!/bin/bash

[[ $OSTYPE =~ darwin* ]] && Apple=true
[[ $OSTYPE =~ linux* ]] && Linux=true

# -----------------------------------------------------------------------------
# Handy aliases to view PATH and LD_LIBRARY_PATH

alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

# -----------------------------------------------------------------------------
# du and df
alias du='du -kh'
[[ $Linux == true ]] && alias df='df -lTh'
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

