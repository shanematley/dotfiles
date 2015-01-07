[ -d ~/.shrc.d/ ] && for f in $(find ~/.shrc.d/ -type f -regex '.*\.\(sh\|bash\)'); do source "$f"; done
