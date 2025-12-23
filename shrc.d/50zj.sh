# zj [query...]
# Interactive zoxide jump with fzf, optionally seeded with a query string.
zj() {
  local query dest
  query="$*"

  dest="$(
    zoxide query -ls \
      | awk '{ $1=""; sub(/^ /,""); print }' \
      | fzf --prompt='zoxide> ' --query="$query"
  )"

  [[ -n "$dest" ]] && cd -- "$dest"
}
