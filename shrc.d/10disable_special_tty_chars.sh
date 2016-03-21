tty >& /dev/null && {
    # disable obsolete special chars in tty
    stty start undef
    stty stop undef
    stty dsusp undef
    stty discard undef
}
