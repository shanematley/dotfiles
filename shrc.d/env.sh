# Sort the output of env(1) for me
env() {
    if [ "$#" -eq 0 ] ; then
        command env | sort
    else
        command env "$@"
    fi
}
