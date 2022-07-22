function gs() {
    echo "$(tput bold)$(tput setaf 4)GIT STATUS$(tput sgr0)"
    git -c color.status=always status -sb|sed 's/^/  /'
    echo "$(tput bold)$(tput setaf 4)OUTGOING$(tput sgr0)"
    git -c color.status=always outgoing|sed 's/^/  /'
    echo "$(tput bold)$(tput setaf 4)RECENT$(tput sgr0)"
    git --no-pager lg --branches -10 --date-order
    echo
}
alias gitn="git --no-pager"


commit_onto() {
    command -v fzf >/dev/null 2>&1 || { echo "commit_onto requires fzf"; return; }

    if [[ $(git diff --name-only --cached | wc -l) -eq 0 ]]; then
        echo 'No changes staged!'
        return
    fi
    local commit
    commit=$(git log --oneline --decorate=no origin/master.. | fzf | cut -d' ' -f1)
    if [[ -z "$commit" ]]; then
        return
    fi
    git commit -m "fixup! $commit"
    GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash
}
