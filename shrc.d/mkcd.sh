# Create a directory and change into it
mkcd() {
    if [[ -n $1 ]]; then
        mkdir -p -- "$1" && cd -- "$1"
    else
        echo "mkcd -- mkdir & cd in one"
        echo "Usage: mkcd directory";
    fi
}
