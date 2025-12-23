dotfiles
========

These are my dotfiles. Currently this includes:

 * Vim Configuration and Vundle bundles
 * Tmux Configuration
 * inputrc

Installation
============

To install:

    ./install.sh [-v] [-p] [-h]

The installation process will create soft-links to the files in this repository,
but will not overwrite files if they already exist. (Soft-links on the other
hand will be replaced.)

Use -v to install VIM vundle and bundles and -p to install powerline

To change shell, run following and log out/in:

    chsh -s /bin/zsh

Vim on Windows
=======================

Vundle files will be installed to %USERPROFILE%\vimfiles\bundle. To accomplish
this add the following to %USERPROFILE%/_vimrc (or appropriate location):

	source %USERPROFILE%\dotfiles\vimrc
	
Then run:

	install_vundle.cmd

Troubleshooting
===============

If for whatever reason git has issues retrieving a remote repository (e.g. Vundle
is failing to install things. Ensure the following is not set in .gitconfig:

    transfer.fsckObjects = true

Troubleshooting Tmux
====================

If tmux is exiting immediately on masOS with "[Exited]", it may be that
reattach-to-user-namespace is not installed. Install this using:

    brew install reattach-to-user-namespace

Profiling ZSH
=============

To time changes to zsh, run the following:

    time zsh -ic exit

To profile, add the following line to the top of `.zshrc` and open a new shell. Then run `zprof|less` to view the profile information.

    zmodload zsh/zprof


