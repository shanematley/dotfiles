#!/bin/bash
#
# Installation script creates links in the user's home directory

FILES=("vimrc" "vim" "tmux" "tmux.conf" "inputrc")
cat <<EOF
This script will create soft links to the following files in the user's home
directory:

    ${FILES[@]}

EOF

while true; do
    read -p "Would you like to continue [Y/N]? " answer
    case $answer in
        [yY]*) echo ""; break;;
        [nN]*) echo "Aborting"; exit;;
    esac
done

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

function create_link {
    local DEST="$HOME/.$1"
    local SRC="$SCRIPTPATH/$1"
    [[ -e "$DEST" && ! -L "$DEST" ]] && { echo "ERROR: $DEST already exists. Skipping."; return 1; }
    echo "Linking $DEST -> $SRC"
    if [[ $(uname -s) == "Darwin" ]]; then
        ln -shf "$SRC" "$DEST"
    else
        ln -snf "$SRC" "$DEST"
    fi
}

for f in "${FILES[@]}"; do
    create_link "$f"
done

echo
echo "Vim and Tmux configuration now in place. To setup Vundle run: ./install_vundle.sh"
