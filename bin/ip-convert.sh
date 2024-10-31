#!/usr/bin/env bash
# This script converts IPV4 addresses between dotted decimal notation (e.g. 172.16.254.1)
# and network order 32-bit decimal numbers (e.g. 2886794753)

ipv4_network_order_to_dotted() {
    local ip_network_order=$1
    printf "%d.%d.%d.%d\n" \
        $(( (ip_network_order >> 24) & 0xFF )) \
        $(( (ip_network_order >> 16) & 0xFF )) \
        $(( (ip_network_order >> 8) & 0xFF )) \
        $(( ip_network_order & 0xFF ))
}

ipv4_dotted_to_network_order() {
    local ip_dotted="$1"
    IFS='.' read -r o1 o2 o3 o4 <<< "$ip_dotted"
    ip_network_order=$(( (o1 << 24) + (o2 << 16) + (o3 << 8) + o4 ))
    echo $ip_network_order
}


is_valid_ipv4_dotted() {
    local ip=$1

    if [[ $ip =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
        for octet in "${BASH_REMATCH[@]:1}"; do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

is_valid_ipv4_network_order() {
    local num=$1
    local max_ip=$((2**32 - 1))  # Derive maximum value for a 32-bit unsigned integer

    if [[ $num =~ ^[0-9]+$ ]]; then
        if (( num >= 0 && num <= max_ip )); then
            return 0
        else
            return 1  # out of range
        fi
    else
        return 1  # not a valid number
    fi
}

if [[ "$1" == "--alfred" ]]; then
    cat<<OUTEREOF
To use $(basename $0) in Alfred, create a script filter with "input as {query}"
with the following script.

This will output the conversion on the "{query}" variable, as well as populate
the "{var:original}" and "{var:converted}" variables.

The script to copy/paste:

result="\$($(readlink -f -- "$0") "{query}")"

if [[ \$? == 0 ]]; then
	cat <<EOF
{
  "items": [
    {
      "title": "IPv4 is \$result",
      "arg": "\$result"
    }
  ],
  "variables": {
    "original": "{query}",
    "converted": "\$result"
  }
}
EOF
else
	cat <<EOF
{
  "items": [
    {
      "title": "Bad input {query}",
      "subtitle": "\$result"
    }
  ]
}
EOF
fi
OUTEREOF

    exit
fi

if is_valid_ipv4_dotted "$1"; then
    ipv4_dotted_to_network_order "$1"
elif is_valid_ipv4_network_order "$1"; then
    ipv4_network_order_to_dotted "$1"
else
    echo "Invalid ipv4 address. '$1' is neither an IPV4 dotted string or network order (big-endian) decimal"
    exit 1
fi

