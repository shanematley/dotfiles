#!/bin/bash

[[ ! -d ./vim ]] && { echo "./vim does not exist. Aborting"; exit 1; }
[[ ! -d ./vim/bundle ]] && mkdir ./vim/bundle
if [[ ! -d ./vim/bundle/Vundle.vim ]]; then
    git clone https://github.com/gmarik/Vundle.vim.git ./vim/bundle/Vundle.vim
else
    echo "Skipping cloning of Vundle. Already present and will upgrade itself."
fi
vim +PluginInstall +qall
