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

FILES=("vimrc" "vim" "tmux" "tmux.conf" "tmux.conf.darwin" "inputrc" "shrc.d" "gitconfig.common" "tmux.conf.pre2.2")
cat <<EOF
This script will create soft links to the following files in the user's home
directory:

    ${FILES[@]}

This script will also setup powerline config.

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

# Select a appropriate script file. E.g. echo zshrc.darwin if present, otherwise zshrc.default
function select_file() {
    local os=$(uname -s|tr '[:upper:]' '[:lower:]')
    local file="$SCRIPTPATH/$1.default"
    [[ -f $SCRIPTPATH/$1.${os} ]] && file="$SCRIPTPATH/$1.${os}"
    echo "$file"
}

function shrc_correct() {
    local type_name="$1"
    local dest_path="$2"
    local source_path="$3"
    diff -q <(sed '/SM: -- Begin offload -- '"$type_name"'/,/SM: -- End offload -- '"$type_name"'/!d; /^#/d' "$dest_path" 2>/dev/null) "$source_path" >/dev/null
}

function shrc_append() {
    local type_name="$1"
    local dest_path="$2"
    local source_path="$3"
    cat <<-EOF >> $dest_path
		# SM: -- Begin offload -- $type_name
		$(<$source_path)
		# SM: -- End offload -- $type_name
		EOF
}

function check_shrc() {
    local source_path=$(select_file "$1")
    local source_file=$(basename "$source_path")
    local dest_path="$HOME/.$1"
    if shrc_correct "$1" "$dest_path" "$source_path"; then
        info "Skipping: $1 set correctly"
        return
    elif [[ ! -f $dest_path ]]; then
        info "Creating ~/.$1 and offloading to $source_file"
        shrc_append "$1" "$dest_path" "$source_path"
    elif ! grep -q 'SM: -- Begin offload -- '"$1" "$dest_path"; then
        info "Editing ~/.$1 with offloading to $source_file"
        shrc_append "$1" "$dest_path" "$source_path"
    else
        info "Replacing .$1 to update .shrc.d processing with $source_file. Backup at .$1.old"
        sed -i.old '/SM: -- Begin offload -- '$1'/,/SM: -- End offload -- '$1'/ {//!d;}; /SM: -- Begin offload/r'"$source_path" "$dest_path"
    fi

    if shrc_correct "$1" "$dest_path" "$source_path"; then
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
    create_link "$SCRIPTPATH/$f" "$HOME/.$f"
done

section "Linking powerline configuration"

create_link "$SCRIPTPATH/powerline" "$HOME/.config/powerline"

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

echo
if yesno "Would you like to install powerline?"; then
    if [[ $(uname -s) == Darwin ]]; then
        echo "Not setup yet"
    else
        pip install --user powerline-status
    fi
fi
