#!/bin/zsh

echo "Updating zgen $(date)"

if [ -z "${ZGEN_SYSTEM_RECEIPT_F}" ]; then
    ZGEN_SYSTEM_RECEIPT_F='.zgen_system_lastupdate'
fi

if [ -z "${ZGEN_PLUGIN_RECEIPT_F}" ]; then
    ZGEN_PLUGIN_RECEIPT_F='.zgen_plugin_lastupdate'
fi

source ~/.shrc.d/00zgen/zgen.zsh
#zgen reset
load_cmds=$(grep -h -r --include="*.zsh" "^ *zgen load.*" ~/.shrc.d/* ~/.shrc.d.local/* | awk '{$1=$1};1')
while read -r load_cmd; do
    eval $load_cmd
done <<< "$load_cmds"
zgen update
zgen save
zgen list
echo "Writing date to ${ZGEN_SYSTEM_RECEIPT_F}"
date +%s >! ~/${ZGEN_SYSTEM_RECEIPT_F}
date +%s >! ~/${ZGEN_PLUGIN_RECEIPT_F}
