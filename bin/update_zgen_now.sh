#!/bin/zsh

[[ ! -f ~/.zgen/init.zsh ]] && { echo "No ~/.zgen/init.zsh file. Can't update"; exit 1 }

zsh -c '
echo "Updating zgen $(date)"
source ~/.zshrc
ZGEN_PLUGIN_UPDATE_DAYS=0 ZGEN_SYSTEM_UPDATE_DAYS=0 zgen load unixorn/autoupdate-zgen
zgen save
'

