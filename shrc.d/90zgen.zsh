#!/bin/zsh

if ! zgen saved; then
    echo "Creating a zgen save"
    zgen save
fi
