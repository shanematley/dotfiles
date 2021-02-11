#!/bin/zsh

# if the init scipt doesn't exist
if ! zgen saved; then
    zgen load willghatch/zsh-cdr
    # Fish shell-like syntax highlighting
    zgen load zsh-users/zsh-syntax-highlighting
    # Directory listings for zsh with git features
    zgen load supercrabtree/k
    # Jump back to a specific parent directory instead of typing cd ../.. redundantly (use bd <name>)
    zgen load Tarrasch/zsh-bd
    # anything.el like widget - Trigger with "Ctrl-x ;" Two main actions (Enter/alt-Enter) + tab for list
    zgen load zsh-users/zaw
    # a selection of useful git scripts
    zgen load unixorn/git-extra-commands
    # Plugin that generates completion functions automatically from getopt-style help texts.
    zgen load RobSis/zsh-completion-generator
    # Set up easy auto updating, both of zgen and the bundles loaded in your configuration.
    #zgen load unixorn/autoupdate-zgen
    # Fish-like suggestions. It suggests commands as you type, based on command history.
    zgen load zsh-users/zsh-autosuggestions
fi

