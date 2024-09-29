#!/bin/bash

# Check OS. Use -n to check it is not that OS.
osis() {
    local n=0
    if [[ $1 == -n ]]; then n=1; shift; fi
    uname -s|grep -i "$1" >/dev/null
    return $(( n ^ $? ))
}