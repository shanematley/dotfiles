#!/bin/bash

# Initialize zoxide for smart directory jumping
# zoxide tracks directories based on frecency (frequency + recency)
# and provides a database that works across shells

if command -v zoxide >/dev/null 2>&1; then
    # --hook pwd: Track every directory change
    if [[ -n $ZSH_VERSION ]]; then
        eval "$(zoxide init zsh --hook pwd)"
    elif [[ -n $BASH_VERSION ]]; then
        eval "$(zoxide init bash --hook pwd)"
    fi
fi
