#!/bin/zsh

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

setopt append_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt share_history
setopt hist_verify
setopt inc_append_history

if [[ $ZSH_VERSION[1] -ge 5 ]]; then
    setopt hist_lex_words
    function _hist_ignore() { [[ ! ( "$1" =~ "fg.*" ) ]] }
    autoload -Uz add-zsh-hook
    add-zsh-hook zshaddhistory _hist_ignore
fi

