#!/bin/bash
#
# Installation script creates links in the user's home directory

set -uo pipefail

section()   { printf "\n## $1\n\n"; }
info ()     { printf "\r  [ \033[00;34m..\033[0m ] $1\n"; }
user ()     { printf "\r  [ \033[0;33m??\033[0m ] $1\n"; }
success ()  { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"; }
fail ()     { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"; echo ''; exit; }
softfail () { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"; }

SCRIPTPATH=$(cd $(dirname $0); pwd;)
FILES=("vimrc" "vim" "tmux" "tmux.conf" "inputrc" "shrc.d" "gitconfig.common" "powerline:$HOME/.config/powerline" "man:$HOME/man")

function yesno {
    while true; do
        read -p "$1 [y/n] " -n 1 -r; echo
        case $REPLY in
            [yY]) return 0;;
            [nN]) return 1;;
        esac
    done
}

read -r -d '' USAGE_MSG <<EOF
USAGE

    $(basename $0) [-hvp]

OPTIONS

    -h  Show this help message
    -v  Install VIM vundle and bundles
    -p  Install powerline

EOF

while getopts ":vph" opt; do
    case $opt in
        v) INSTALL_OPTION_VIM=1;;
        p) INSTALL_OPTION_POWERLINE=1;;
        h) echo "$USAGE_MSG"; exit 0;;
        \?) fail "Invalid option: $OPTARG";;
    esac
done

: ${INSTALL_OPTION_VIM:=}
: ${INSTALL_OPTION_POWERLINE:=}

cat <<EOF
Actions to be taken:

 * Create soft links to the following files in the user's home directory:

EOF
for f in "${FILES[@]}"; do echo "    $f"; done

[[ $INSTALL_OPTION_VIM ]] && echo -e "\n * VIM vundle and bundles will be installed."; 
[[ $INSTALL_OPTION_POWERLINE ]] && echo -e "\n * Powerline will be installed."; 
echo

yesno "Would you like to continue?" || fail "Aborting" 

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

for f in "${FILES[@]}"; do
    [[ $f =~ ([^:]+):?(.*)? ]] || fail "Bad file specified in FILES. Adjust script. File: '$f'"
    DEST="${BASH_REMATCH[1]}"
    LINK="${BASH_REMATCH[2]:-${HOME}/.${DEST}}"
    create_link "$SCRIPTPATH/$DEST" "$LINK"
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

section "Generating awk files"

for f in "$SCRIPTPATH/bin/"*"awk"; do
    fbase=$(basename "$f")
    fdest=${fbase%.*}
    "$SCRIPTPATH/bin/shb" "$f" awk -f > "$HOME/bin/$fdest"
    chmod +x "$HOME/bin/$fdest"
    success "Generated $fdest from $fbase"
done

section "Prerequisites"

# Check for tmux-mem-cpu-load presence
if ! command -v tmux-mem-cpu-load >/dev/null 2>&1; then
    softfail "tmux-mem-cpu-load missing. Install via brew install tmux-mem-cpu-load or equivalent"
else
    info "tmux-mem-cpu-load present"
fi


# Offer to install VIM bundles
if [[ $INSTALL_OPTION_VIM ]]; then
    section "Installing Vundle for VIM"

    [[ ! -d ~/.vim ]] && fail "./vim does not exist. Aborting"
    [[ ! -d ~/.vim/bundle ]] && mkdir ~/.vim/bundle
    if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
        git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim && success "Vundle installed"
    else
        info "Skipping cloning of Vundle. Already present and will upgrade itself."
    fi
    section "Installing Vundle bundles"
    if vim +PluginInstall +qall; then
        success "Vundble bundles installed/upgraded"
    else
        fail "An error occurred while installing Vundle bundles"
    fi
fi

if [[ $INSTALL_OPTION_POWERLINE ]]; then
    section "Installing powerline"
    if [[ $(uname -s) == Darwin ]]; then
        pip install powerline-status
        ln -s $(pip show powerline-status|awk '/Location/ { print $2}')/powerline/bindings/zsh/powerline.zsh ~/bin/
        pip install psutil # For uptime
    else
        pip install --user powerline-status
    fi
fi
