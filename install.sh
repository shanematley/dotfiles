#!/bin/bash
#
# Installation script creates links in the user's home directory

FILES=("vimrc" "vim" "tmux" "tmux.conf" "inputrc" "shrc.d" "gitconfig")
cat <<EOF
This script will create soft links to the following files in the user's home
directory:

    ${FILES[@]}

EOF

function yesno {
    local QUESTION="$1"
    while true; do
        read -p "$QUESTION [y/n] " answer
        case $answer in
            [yY]*) return 0;;
            [nN]*) return 1;;
        esac
    done
}

yesno "Would you like to continue?" || { echo "Aborting"; exit; }

# Determine where we are in a reasonably cross-platform manner
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

function append_shrc() {
    echo "Updating .$1 to include .shrc.d processing"
    cat "$SCRIPTPATH/$1" >> $HOME/.$1
}

function check_shrc() {
    # Append or replace .{bash,zsh}rc offloading
    if [[ -f $HOME/.$1 ]]; then
        if ! grep 'SM: -- Begin offload' $HOME/.$1 > /dev/null ; then
            append_shrc "$1"
        else
            echo "Replacing .$1 to update .shrc.d processing. Backup at .$1.old"
            sed -i.old '/SM: -- Begin offload/,/SM: -- End offload/ {//!d}; /SM: -- Begin offload/r'$1 $HOME/.$1
        fi
    else
        append_shrc "$1"
    fi
}

check_shrc zshrc
check_shrc bashrc

# Create softlinks
for f in "${FILES[@]}"; do
    create_link "$f"
done

# Offer to install VIM bundles
echo
echo "Vim and Tmux configuration now in place."
if yesno "Would you like to install vim vundle and its bundles?"; then
    ./install_vundle.sh
else
    echo "Ok. If you want to later run: ./install_vundle.sh"
fi

