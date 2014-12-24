# Offload to individual files
[ -d ~/.shrc.d ] && for f in $(find -E ~/.shrc.d/ -type file -regex '.*\.(sh|zsh)'); do source "$f"; done
