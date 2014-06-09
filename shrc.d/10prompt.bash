#!/bin/bash
# To enable VCS information enable via the following:
#   ENABLE_VCS_PROMPT=1
#   ENABLE_GIT_PROMPT=1
#   ENABLE_HG_PROMPT=1
#
# (Note Git prompt will default to the builtin support if present.)
#
# To enable/disable vcs integration run the following at any time:
#   enable_vcs_prompt
#   disable_vcs_prompt

[[ $OSTYPE =~ darwin* ]] && Apple=true
[[ $OSTYPE =~ linux* ]] && Linux=true

prompt_git() {
    git branch &>/dev/null || return 1
    HEAD="$(git symbolic-ref HEAD 2>/dev/null)"
    BRANCH="${HEAD##*/}"
    #[[ -n "$(git status 2>/dev/null | \
    #    grep -F 'working directory clean')" ]] || STATUS="!"
    # This appears much quicker though won't indicate untracked files
    git diff --quiet &>/dev/null || STATUS="!"
    printf ' (git:%s)' "${BRANCH:-unknown}${STATUS}"
}
prompt_hg() {
    hg branch &>/dev/null || return 1
    BRANCH="$(hg branch 2>/dev/null)"
    [[ -n "$(hg status 2>/dev/null)" ]] && STATUS="!"
    printf ' (hg:%s)' "${BRANCH:-unknown}${STATUS}"
}
prompt_svn() {
    svn info &>/dev/null || return 1
    URL="$(svn info 2>/dev/null | \
        awk -F': ' '$1 == "URL" {print $2}')"
    ROOT="$(svn info 2>/dev/null | \
        awk -F': ' '$1 == "Repository Root" {print $2}')"
    BRANCH=${URL/$ROOT}
    BRANCH=${BRANCH#/}
    BRANCH=${BRANCH#branches/}
    BRANCH=${BRANCH%%/*}
    [[ -n "$(svn status 2>/dev/null)" ]] && STATUS="!"
    printf ' (svn:%s)' "${BRANCH:-unknown}${STATUS}"
}
prompt_vcs() {
    prompt_git
}
prompt_jobs() {
    [[ -n "$(jobs)" ]] && printf ' {%d}' $(jobs | sed -n '$=')
}

enable_vcs_prompt() {
    # With built-in git completion support:
    if type -t __git_ps1 &>/dev/null; then
        export GIT_PS1_SHOWSTASHSTATE=1
        export GIT_PS1_SHOWDIRTYSTATE=1
        export GIT_PS1_SHOWUPSTREAM="git"
        export PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w]\[\033[00m\]\$(__git_ps1 ' (%s)')\$(prompt_jobs) "
    else
        export PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w]\[\033[00m\]\$(prompt_vcs)\$(prompt_jobs) "
    fi
}

disable_vcs_prompt() {
    export PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[0m\]]\$(prompt_jobs) "
}

if [[ -n $PS1 ]]; then
    if [[ $ENABLE_VCS_PROMPT == 1 || $ENABLE_GIT_PROMPT == 1 ]]; then
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

