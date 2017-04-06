
if [[ $(uname -s) == 'Darwin' ]]; then

    function copyhead() {
        local head_ref=$(git rev-parse --verify HEAD|tr -d '\n')
        echo "$head_ref" | pbcopy
        echo "Copied HEAD to pasteboard ($head_ref)"
    }

fi
