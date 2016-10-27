# Format an RFC in text format for terminal reading

# A record is a paragraph
BEGIN {
    RS=""
}

# Skip any block without at least one alphanumeric char
!/[[:alnum:]]/ { next }

# Skip any block with a page break marker in it
/\x0c/ { next }

# Print the block followed by two newlines
{ printf "%s\n\n", $0 }
