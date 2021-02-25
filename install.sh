#!/bin/bash
#
# Installation script creates links in the user's home directory

set -uo pipefail

section()   { printf "\n## $1\n\n"; }
info()      { printf "\r  [ \033[00;34m..\033[0m ] $1\n"; }
user()      { printf "\r  [ \033[0;33m??\033[0m ] $1\n"; }
success()   { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"; }
fail()      { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"; echo ''; exit; }
softfail () { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"; }

SCRIPTPATH=$(cd $(dirname $0); pwd;)
KONSOLE_THEMES=~/.local/share/konsole
FILES=("vimrc"
    "vim"
    "tmux"
    "tmux.conf"
    "inputrc"
    "shrc.d"
    "gdbinit"
    "gitconfig.common"
    "tridactylrc"
    "ideavimrc"
    "powerline:$HOME/.config/powerline"
    "karabiner:$HOME/.config/karabiner"
    "man:$HOME/man")

osis() {
    local n=0
    if [[ "$1" == "-n" ]]; then n=1; shift; fi
    uname -s|grep -i "$1" >/dev/null
    return $(( $n ^ $? ))
}

function yesno {
    while true; do
        read -p "$1 [y/n] " -n 1 -r; echo
        case $REPLY in
            [yY]) return 0;;
            [nN]) return 1;;
        esac
    done
}

usage() {
    cat << EOF
USAGE
    $(basename $0) [options]

OPTIONS
    -h  Show this help message
    -v  Install VIM plugins
    -p  Install Powerline
EOF
    exit $1
}

while getopts ":vph" opt; do
    case $opt in
        v) INSTALL_OPTION_VIM=1;;
        h) usage 0;;
        p) INSTALL_POWERLINE=1;;
        \?) fail "Invalid option: $OPTARG";;
    esac
done

: ${INSTALL_OPTION_VIM:=}
: ${INSTALL_POWERLINE:=}

cat <<EOF
Actions to be taken:

 * Create soft links to the following files in the user's home directory:

EOF
for f in "${FILES[@]}"; do echo "    $f"; done

[[ $INSTALL_OPTION_VIM ]] && echo -e "\n * VIM plugins will be installed."; 
echo

yesno "Would you like to continue?" || fail "Aborting" 

function create_link {
    local SRC="$1"
    local DEST="$2"
    [[ -e "$DEST" && ! -L "$DEST" ]]                   && { softfail "ERROR: $DEST already exists. Skipping."; return 1; }
    [[ -L "$DEST" && $(readlink "$DEST") -ef "$SRC" ]] && { info "Skipping: $DEST already points to correct file."; return 0; }
    if osis Darwin; then
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

function create_dir {
    local DEST="$1"
    [[ -d "$DEST" ]] && { info "Skipping: directory $DEST already exists."; return 0; }
    if mkdir -p "$DEST"; then
        success "Created directory $DEST"
    elif [[ $# > 1 && $2 == hardfail ]]; then
        fail "Unable to create directory $DEST"
    else
        softfail "Unable to create directory $DEST"
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

function installed() {
    command -v "${1}" >/dev/null 2>&1
}

function sync_brew_package() {
    local command_name="$1"
    local package_name="$2"
    if osis Darwin; then
        if ! installed $command_name; then
            if installed brew; then
                info "Missing $package_name Installing via Homebrew."
                if brew install $package_name; then
                    success "$package_name installed"
                else
                    softfail "$package_name missing. Homebrew installation of $package_name failed"
                fi
            else
                softfail "$package_name missing and unable to install as HomeBrew is missing."
            fi
        else
            info "Skipping: $package_name already present"
        fi
    fi
}

function check_binary_presence() {
    installed "$1" && info "Skipping: $1 already present" || softfail "$1 missing"
}

function sync_pip_package() {
    local package="$1"
    if pip2 show $package >/dev/null; then
        info "Skipping: $package already present"
        return 0
    else
        if ! installed pip2; then
            softfail "$package could not be installed as pip2 missing"
            return 1
        elif pip2 install --user ${package}; then
            success "$package installed"
            return 0
        else
            softfail "$package could not be installed"
            return 1
        fi
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
create_dir "$HOME/bin" hardfail
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

check_binary_presence curl
check_binary_presence git
sync_brew_package reattach-to-user-namespace reattach-to-user-namespace

# Offer to install VIM plugins
if [[ $INSTALL_OPTION_VIM ]]; then
    section "Installing plugins for vim"

    [[ ! -d ~/.vim ]] && fail "./vim does not exist. Aborting"
    if [[ ! -f ~/.vim/autoload/plug.vim ]]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        vim +PlugUpgrade +qall
        info "Upgraded Plug."
    fi

    section "Installing Plug plugins"
    if vim +PlugInstall +qall; then
        success "Plug bundles installed/upgraded"
    else
        fail "An error occurred while installing Plug bundles"
    fi
fi

if [[ $INSTALL_POWERLINE ]]; then
    section "Powerline"

    if osis Darwin; then
        sync_pip_package powerline-status && create_link $(pip2 show powerline-status|awk '/Location/ { print $2}')/powerline/bindings/zsh/powerline.zsh ~/bin/powerline.zsh
        sync_pip_package psutil
    else
        sync_pip_package powerline-status
    fi
fi

install_zsh_plugins() {
    local zfunction_src="$SCRIPTPATH/zfunctions"
    local zfunction_dst="$HOME/.zfunctions"

    section "ZSH Plugins"

    # Used in conjunction with 10zfunctions.sh to provide additional ZSH functionality
    if [[ "${zfunction_src}" -ef "${zfunction_dst}" ]]; then
        rm "${zfunction_dst}" && success "ZSH Plugins: Removed old symlink"
    fi
    mkdir "${zfunction_dst}" 2>/dev/null && success "ZSH Plugins: Created ${zfunction_dst}" || info "ZSH Plugins: ${zfunction_dst} already present"
    for file in "${zfunction_src}/"*; do
        create_link "${file}" "${zfunction_dst}/${file/*\//}"
    done
}

install_zsh_plugins


section "Submodules"

git submodule sync
git submodule update --init

section "Konsole/Yakuake"

function install_theme() {
    local theme_source="$1"
    local theme_name="$(basename "$theme")"
    local dest_path="$KONSOLE_THEMES/$theme_name"
    if [[ ! -f $dest_path ]]; then
        if cp "$theme_source" "$dest_path"; then
            success "Installed theme $theme_name"
        else
            softfail "Failed to install theme $theme_name"
        fi
    else
        if diff -q "$theme_source" "$dest_path" >/dev/null; then
            info "Theme $theme_name already installed"
        else
            softfail "Theme $theme_name already exists. Manually remove $dest_path if you wish to reinstall"
        fi
    fi
}

if [[ -d ~/.local/share/konsole ]]; then
    for theme in "$SCRIPTPATH/konsole_themes/"*; do
        install_theme "$theme"
    done
else
    info "No konsole directory. Not installing konsole_themes"
fi

section "Verifying tools"

function check_vim_option() {
    # No idea why, but -q on grep is not working on linux here...
    if $1 --version|grep '\+'$2 >/dev/null; then
        info "$1 has +$2"
    else
        softfail "$1 does not have +$2"
    fi
}

check_vim_option vim clipboard
osis Linux && check_vim_option vim xterm_clipboard
osis Darwin && check_vim_option mvim clipboard

