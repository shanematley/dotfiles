#!/bin/bash

# Ignore duplicates and lines starting with a space
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
HISTTIMEFORMAT='%F %T '

# Rollup multi-line commands into a single line
shopt -s cmdhist

log_bash_persistent_history()
{
  [[
    $(history 1) =~ ^\ *[0-9]+\ +([0-9-]+\ [0-9:]+)\ +(.*)$
  ]]
  local date_part="${BASH_REMATCH[1]}"
  local command_part="${BASH_REMATCH[2]}"
  if [ "$command_part" != "$PERSISTENT_HISTORY_LAST" ]
  then
    echo $date_part "|" "$command_part" >> ~/.persistent_history
    export PERSISTENT_HISTORY_LAST="$command_part"
  fi
}

run_on_prompt_command()
{
    log_bash_persistent_history
}

PROMPT_COMMAND="run_on_prompt_command"

alias phgrep='cat ~/.persistent_history|grep --color'
alias hgrep='history|grep --color'

alias trim_persistant_history='tail -20000 ~/.persistent_history | tee ~/.persistent_history'

