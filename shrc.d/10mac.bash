
function cdr_to_iso() {
    [[ -z $1 ]] &&  { echo "Usage: cdr_to_iso disk.cdr"; return 1; }
    if [[ $1 =~ (.*)\.cdr$ ]]; then
        echo "Creating ISO: $1 -> ${BASH_REMATCH[1]}.iso"
        hdiutil makehybrid -iso -joliet -o "${BASH_REMATCH[1]}.iso" "$1"
    else
         echo "Usage: cdr_to_iso disk.iso"
         return 1
     fi
}
