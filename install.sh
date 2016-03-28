#!/bin/bash
#
# Installation script creates links in the user's home directory

set -euo pipefail

section() {
    printf "\n## $1\n\n"
}

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

softfail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
}

FILES=("vimrc" "vim" "tmux" "tmux.conf" "inputrc" "shrc.d" "gitconfig.common")
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

yesno "Would you like to continue?" || fail "Aborting" 

# Determine where we are in a reasonably cross-platform manner
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

function create_link {
    local SRC="$1"
    local DEST="$2"
    [[ -e "$DEST" && ! -L "$DEST" ]]                   && { softfail "ERROR: $DEST already exists. Skipping."; return 1; }
    [[ -L "$DEST" && $(readlink "$DEST") -ef "$SRC" ]] && { info "Skipping: $DEST already points to correct file."; return 0; }
    if [[ $(uname -s) == "Darwin" ]]; then
        ln -shf "$SRC" "$DEST"
    else
        ln -snf "$SRC" "$DEST"
    fi

    if [[ -L $DEST && $(readlink "$DEST") -ef $SRC ]]; then
        success "Linked $DEST -> $SRC"
    else
        softfail "Unable to link $DEST to $SRC"
    fi
}

function shrc_correct() { diff -q <(sed '/SM: -- Begin offload/,/SM: -- End offload/!d; /^#/d' $HOME/.$1 2>/dev/null) $SCRIPTPATH/$1 >/dev/null; }

function check_shrc() {
    if shrc_correct "$1"; then
        info "Skipping: $1 set correctly"
        return
    elif [[ ! -f $HOME/.$1 ]]; then
        info "Creating ~/.$1 and offloading to $SCRIPTPATH/$1"

        cat <<-EOF >> $HOME/.$1
			# SM: -- Begin offload
			$(<$SCRIPTPATH/$1)
			# SM: -- End offload
			EOF
    else
        info "Replacing .$1 to update .shrc.d processing. Backup at .$1.old"
        sed -i.old '/SM: -- Begin offload/,/SM: -- End offload/ {//!d;}; /SM: -- Begin offload/r'$1 $HOME/.$1
    fi

    if shrc_correct "$1"; then
        success "INFO: $1 successfully offloaded"
    else
        fail "Failed to update $1 correctly"
    fi
}

section "Offloading zshrc/bashrc"

check_shrc zshrc
check_shrc bashrc

section "Linking dotfiles"

# Create softlinks
for f in "${FILES[@]}"; do
    create_link "$SCRIPTPATH/$f" "$HOME/$f"
done

section "Adding git common commands"

# Setup git
if git config --get-all include.path|grep -q "$HOME/.gitconfig.common"; then
    info "Skipping: Git already set up"
else
    git config --global --add include.path "$HOME/.gitconfig.common"
    success "Added ~/.gitconfig.common to git global include path"
fi

section "Linking bin files"

# Setup bin files
for f in "$SCRIPTPATH/bin/"*; do
    create_link "$f" "$HOME/bin/$(basename $f)"
done

section "Linking man files"

# Setup man files
create_link "$SCRIPTPATH/man" "$HOME/man"

# Offer to install VIM bundles
echo
echo "Vim and Tmux configuration now in place."
if yesno "Would you like to install vim vundle and its bundles?"; then
    ./install_vundle.sh
else
    echo "Ok. If you want to later run: ./install_vundle.sh"
fi

