dotfiles
========

These are my dotfiles. Currently this includes:

 * Vim Configuration and Vundle bundles
 * Tmux Configuration
 * inputrc

Installation
============

To install:

    ./install.sh

The installation process will create soft-links to the files in this repository,
but will not overwrite files if they already exist. (Soft-links on the other
hand will be replaced.)

Troubleshooting
===============

If for whatever reason git has issues retrieving a remote repository (e.g. Vundle
is failing to install things. Ensure the following is not set in .gitconfig:

    transfer.fsckObjects = true
