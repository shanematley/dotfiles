[ -t 0 ] && {
    # disable obsolete special chars in tty
    stty start undef
    stty stop undef
    stty dsusp undef 2>/dev/null
    stty discard undef 2>/dev/null
}
