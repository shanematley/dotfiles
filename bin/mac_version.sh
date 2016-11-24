#!/bin/bash

MAC_VERSION_STR=$(system_profiler SPSoftwareDataType|grep 'System Version'|grep -oE '\d+\.\d+\.\d+')

if [[ $MAC_VERSION_STR =~ 10\.12.* ]]; then
    echo "Sierra"
elif [[ $MAC_VERSION_STR =~ 10\.11.* ]]; then
    echo "El Capitan"
elif [[ $MAC_VERSION_STR =~ 10\.10.* ]]; then
    echo "Yosemite"
elif [[ $MAC_VERSION_STR =~ 10\.9.* ]]; then
    echo "Mavericks"
elif [[ $MAC_VERSION_STR =~ 10\.8.* ]]; then
    echo "Mountain Lion"
elif [[ $MAC_VERSION_STR =~ 10\.7.* ]]; then
    echo "Lion"
elif [[ $MAC_VERSION_STR =~ 10\.6.* ]]; then
    echo "Snow Leopard"
elif [[ $MAC_VERSION_STR =~ 10\.5.* ]]; then
    echo "Leopard"
elif [[ $MAC_VERSION_STR =~ 10\.4\.4 ]]; then
    echo "Tiger (Intel)"
elif [[ $MAC_VERSION_STR =~ 10\.4\.[0-3] ]]; then
    echo "Tiger (PowerPC)"
elif [[ $MAC_VERSION_STR =~ 10\.3.* ]]; then
    echo "Panther"
elif [[ $MAC_VERSION_STR =~ 10\.2.* ]]; then
    echo "Jaguar"
elif [[ $MAC_VERSION_STR =~ 10\.1.* ]]; then
    echo "Puma"
elif [[ $MAC_VERSION_STR =~ 10\.0.* ]]; then
    echo "Cheetah"
else
    echo "Unknown"
fi
