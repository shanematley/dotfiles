
# Offload to individual files
[ -d ~/.shrc.d ] && for f in ~/.shrc.d/*.{sh,bash}; do . "$f"; done
[ -d ~/.shrc.d/local ] && for f in ~/.shrc.d/local/*.{sh,bash}; do . "$f"; done

