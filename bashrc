
# Offload to individual files
[ -d ~/.shrc.d ] && for f in ~/.shrc.d/*.{sh,bash}; do . "$f"; done

