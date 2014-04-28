GREP_OPTIONS=--color
for PATTERN in .cvs .git .hg .svn; do
    GREP_OPTIONS="$GREP_OPTIONS --exclude-dir=$PATTERN"
done

export GREP_OPTIONS
