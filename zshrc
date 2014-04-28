# Offload to individual files
[ -d ~/.shrc.d ] && for f in ~/.shrc.d/*.{sh,zsh}; do source "$f"; done
