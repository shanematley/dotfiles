[ -d ~/.shrc.d ] && for f in $(find ~/.shrc.d/ -type f -regex '.*\.\(sh\|zsh\)'); do source "$f"; done
