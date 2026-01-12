# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

_gf() {
  is_in_git_repo || return

  local modified_files result key selected_files
  modified_files=$(git status --short --porcelain | cut -c4- | sed 's/^"//; s/"$//')

  result=$(
    (
      # Modified/staged/untracked files first with [MODIFIED] marker
      echo "$modified_files" | sed 's/$/ [MODIFIED]/'
      # All other tracked files (excluding already shown modified ones)
      comm -23 \
        <(git ls-files | sort) \
        <(echo "$modified_files" | sort)
    ) | fzf-down -m --ansi --expect=alt-enter \
      --preview 'file=$(echo {} | sed "s/ \[MODIFIED\]$//");
                  (git diff --color=always -- "$file" 2>/dev/null | sed 1,4d;
                   bat --color=always "$file" 2>/dev/null || cat "$file")'
  )

  key=$(head -1 <<< "$result")
  selected_files=$(tail -n +2 <<< "$result" | sed 's/ \[MODIFIED\]$//')

  if [[ -z "$selected_files" ]]; then
    return
  fi

  if [[ "$key" == "alt-enter" ]]; then
    # Output vim and files on separate lines so join-lines quotes each correctly
    echo "vim"
    echo "$selected_files"
  else
    # Return files for command line insertion (one per line for join-lines)
    echo "$selected_files"
  fi
}

_gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

_gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

_gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

_gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

# Completion for git when used with `FZF_COMPLETION_TRIGGER`
# Info: https://github.com/junegunn/fzf?tab=readme-ov-file#custom-fuzzy-completion
#
# Example usage:
# - complete on commits: `git rebase **<tab>`
# - complete on files: `git log -- **<tab>`
_fzf_complete_git() {
    _fzf_complete \
        --preview='git show --color=always {1}' \
        --preview-window=wrap,~6 \
        -- "$@" < <(
            if [[ "$*" == *"--"* ]]; then
                git ls-files
            else
                git log --pretty="%h %d %s (%an, %cr)"
            fi
        )
}

_fzf_complete_git_post() {
    cut -d ' ' -f1
}

