function gs() {
    echo "$(tput bold)$(tput setaf 4)GIT STATUS$(tput sgr0)"
    git -c color.status=always status -sb|sed 's/^/  /'
    echo "$(tput bold)$(tput setaf 4)OUTGOING$(tput sgr0)"
    git -c color.status=always outgoing|sed 's/^/  /'
    echo "$(tput bold)$(tput setaf 4)RECENT$(tput sgr0)"
    git --no-pager graph -10
    echo
}
alias gitn="git --no-pager"
