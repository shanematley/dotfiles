#!/bin/zsh

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=1024
export SAVEHIST=1024

setopt append_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt share_history
setopt hist_verify
setopt inc_append_history

if [[ $ZSH_VERSION[1] -ge 5 ]]; then
    setopt hist_lex_words
    function _hist_ignore() { [[ ! ( "$1" =~ "fg.*" ) ]] }
    autoload -Uz add-zsh-hook
    add-zsh-hook zshaddhistory _hist_ignore
fi

