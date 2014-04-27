
# Offload to individual files
[ -d ~/.bashrc.d ] && for f in ~/.bashrc.d/*; do . "$f"; done
