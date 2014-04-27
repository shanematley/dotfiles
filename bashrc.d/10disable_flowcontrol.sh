#!/bin/bash

if [ -n "$PS1" ]; then
    # Turn off flow control completely
    stty -ixon
fi

