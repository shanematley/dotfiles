function branch_todos()
{
    if [[ -z $1 ]]; then
        cat<<EOF
USAGE
        branch_todos base_branch [branch_to_check]

DESCRIPTION
        List files changed in a branch containing TODO.

EXAMPLES

        Check TODOs in files changed between origin/master and HEAD:
            branch_todos origin/master
        
        Check TODOs in files changed in master:
            branch_todos origin/master master
EOF
        return 1
    fi
    grep TODO "$(git diff "$1"..."$2" --name-only)" | sed 's/:.*//' | uniq -c
}
