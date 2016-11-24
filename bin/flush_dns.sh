#!/bin/bash

trap 'echo "Failed to flush DNS cache"' 0
set -e

MAC_VERSION_STR=$(system_profiler SPSoftwareDataType|grep 'System Version'|grep -oE '\d+\.\d+\.\d+')

if [[ $MAC_VERSION_STR =~ 10\.(12.*|11.*|10\.4|9.*|8.*|7.*) ]]; then
    echo "Sierra (10.12), El Capitan (10.11), Yosemite (10.10.4), Mavericks (10.9), Mountain Lion (10.8) or Lion (10.7)"
    sudo dscacheutil -flushcache && echo "Flushed cache using dscacheutil"
    sudo killall -HUP mDNSResponder && echo "Killed mDNSResponder"
elif [[ $MAC_VERSION_STR =~ 10\.10\.[0-3] ]]; then
    echo "Yosemite (10.10.0-3)"
    sudo discoveryutil mdnsflushcache && echo "Flushed cache using discoveryutil"
elif [[ $MAC_VERSION_STR =~ 10\.[56].* ]]; then
    echo "Snow Leopard (10.6) or Leopard (10.5)"
    sudo dscacheutil -flushcache && echo "Flushed cache using dscacheutil"
else
    echo "Not sure how to flush cache for this version of macOS"
fi

trap : 0
