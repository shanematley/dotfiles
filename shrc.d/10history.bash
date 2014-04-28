#!/bin/bash

# Ignore duplicates and lines starting with a space
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
HISTTIMEFORMAT='%F %T '

# Rollup multi-line commands into a single line
shopt -s cmdhist
