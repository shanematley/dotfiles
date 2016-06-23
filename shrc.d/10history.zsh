#!/bin/zsh

export HISTFILE=~/.zsh_history
export HISTSIZE=1024
export SAVEHIST=1024

setopt append_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt share_history
setopt hist_verify
setopt inc_append_history

alias fg=" fg"
