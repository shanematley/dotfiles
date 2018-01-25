#!/bin/zsh

autoload -U colors && colors

# Simple prompt for when there are no zsh prompts installed
#
# For additional information on the options available, refer to
# section EXPANSION OF PROMPT SEQUENCES of zshmisc(1)
prepare_prompt() {
    local -a parts
    # Username@Host
    parts+=("%F{yellow}%n@%m%f")
    # Working directory
    parts+=(":%F{blue}%~%f")
    # Date/Time
    parts+=(" %F{10}[%D{%Y-%m-%d %T %Z}]%f")
    # Jobs
    parts+=(" %F{9}%(1j.{%j} .)%f")
    # Prompt
    parts+=($'\n'"%(?.%F{magenta}.%F{red})❯%f ")

    PROMPT="${(j..)parts}"
    export PROMPT
}
prepare_prompt

