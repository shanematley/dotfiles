#!/bin/bash
# To enable VCS information enable via the following:
#   ENABLE_GIT_PROMPT=1
#
# (Note Git prompt will default to the builtin support if present.)
#
# To enable/disable vcs integration run the following at any time:
#   enable_vcs_prompt
#   disable_vcs_prompt

prompt_git() {
    git branch &>/dev/null || return 1
    HEAD="$(git symbolic-ref HEAD 2>/dev/null)"
    BRANCH="${HEAD##*/}"
    #[[ -n "$(git status 2>/dev/null | \
    #    grep -F 'working directory clean')" ]] || STATUS="!"
    # This appears much quicker though won't indicate untracked files
    git diff --quiet &>/dev/null || STATUS="!"
    printf ' %s' "${BRANCH:-unknown}${STATUS}"
}

prompt_jobs() {
    [[ -n "$(jobs)" ]] && printf ' {%d}' $(jobs | sed -n '$=')
}

create_my_prompt() {
    local VCS_PROMPT="$1"
    local IN_DOCKER=""

    [[ -f /.dockerenv ]] && IN_DOCKER="(Docker) "

    export PS1="\[\033[34m\]\w\[\033[30m\]${VCS_PROMPT} \u@\h\$(prompt_jobs)\n\[\033[35m\]${IN_DOCKER}λ \[\033[0m\]"
}

enable_vcs_prompt() {
    # With built-in git completion support:
    local VCS_PROMPT=
    if type -t __git_ps1 &>/dev/null; then
        export GIT_PS1_SHOWSTASHSTATE=1
        export GIT_PS1_SHOWDIRTYSTATE=1
        export GIT_PS1_SHOWUPSTREAM="git"
        create_my_prompt "\$(__git_ps1 ' (%s)')"
    else
        create_my_prompt "\$(prompt_git)"
    fi
}

disable_vcs_prompt() {
    create_my_prompt ""
}


if [[ -n $PS1 ]]; then
    if [[ $ENABLE_GIT_PROMPT == 1 ]]; then
        enable_vcs_prompt
    else
        disable_vcs_prompt
    fi

    # On Debian or Ubuntu, if this is an xterm set the title to user@host:dir
    if [[ -f /etc/debian_version ]]; then
        case "$TERM" in
            xterm*|rxvt*) export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\H: \w\a\]$PS1" ;;
            *) ;;
        esac
    fi
fi

