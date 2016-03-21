if [[ $(uname -s) == Darwin ]]; then
    [ -d ~/.shrc.d/ ] && for f in $(find -E ~/.shrc.d/ -type f -regex '.*\.(sh|bash)'); do source "$f"; done
else
    [ -d ~/.shrc.d/ ] && for f in $(find ~/.shrc.d/ -type f -regex '.*\.\(sh\|bash\)'); do source "$f"; done
fi
