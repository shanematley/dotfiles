# Offload to individual files
[ -d ~/.shrc.d ] && for f in ~/.shrc.d/*.{sh,zsh}; do source "$f"; done
[ -d ~/.shrc.d/local ] && for f in ~/.shrc.d/local/*.{sh,zsh}; do source "$f"; done
