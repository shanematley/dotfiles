#!/bin/bash
# Create an ISO from a disk

function usage() {
    echo "USAGE"
    echo "    $(basename $0) device [output.iso]"
    echo
    echo "DEVICES"
    df | grep '^/dev/disk' | sed 's/^/    /'
}

[[ -z $1 ]] && { usage; exit 1; }
DISKDEV="$1"
OUTPUT="$2"

if [[ -z $2 ]]; then
    # Create iso name from device mount path
    VOLUME_LABEL=$(diskutil info "$DISKDEV" | grep 'Volume Name' | sed 's/.*Volume Name: *//')
    OUTPUT="$VOLUME_LABEL.iso"
fi

echo "Creating ISO from $DISKDEV to $OUTPUT"
sudo diskutil unmount $DISKDEV
hdiutil makehybrid -iso -joliet -o "$OUTPUT" $DISKDEV
#diskutil eject $DISKDEV
