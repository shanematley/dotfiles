function rgdelta {
    rg --json -C 2 "$@" | delta
}
