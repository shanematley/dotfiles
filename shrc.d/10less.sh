#!/bin/bash

export PAGER=less
export LESSCHARSET='utf-8'

# -g Highlight only the match on the particular string from by the last search command, not ALL strings.
# -w Temporarily highlights the first "new" line after a forward movement of a full page.
# -R Causes raw control characters to be displayed
# -P Custom prompt: (filename|stdin) position of the bottom line in file (in order of preference: % in file, or line #, or bytes
#       ?f ... : ... . - if there is an input file. E.g. "?f%f :stdin ." will print filename followed by space, or "stdin "
#       %f - current input file name
#       ?pb - if % into file in terms of bytes is known using bottom line as the reference point
#       %pb - % into file in bytes (vs lines) using bottom line as the reference point
export LESS='-g -w -R -P?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'

