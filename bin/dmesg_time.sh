#!/bin/bash

base=$(cat /proc/uptime | cut -d '.' -f1)
seconds=$(date +%s);
dmesg | while read line; do
    if [[ $line =~ ^\[([0-9]+)\.[0-9]+\]\ (.*) ]]; then
        #echo "Matches: ${BASH_REMATCH[1]} => ${BASH_REMATCH[2]}"
        msg_seconds=${BASH_REMATCH[1]}
        date_value=$(($seconds - $base + $msg_seconds))
        date_formatted=$(date +"%Y-%m-%d %H:%M:%S" --date="@$date_value")
        echo "[$date_formatted] ${BASH_REMATCH[2]}"
    else
        echo $line
    fi
done

