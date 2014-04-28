#!/bin/bash

# The following commands don't work when in a psuedo-terminal such as a non-interactive ssh session.
if [ -n "$PS1" ]; then
    # Turn off the beep in certain annoying circumstances, e.g. no autocomplete results
    if which setterm &> /dev/null; then
        setterm -bfreq 0
    fi
fi

