#!/bin/bash

if [ -n "$PS1" ] && [ -t 0 ]; then
    # Turn off flow control completely
    stty -ixon
fi

