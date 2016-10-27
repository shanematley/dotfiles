# Create a directory and change into it
mkcd() {
    mkdir -p -- "$1" && command cd -- "$1"
}
