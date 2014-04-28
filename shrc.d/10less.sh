#!/bin/bash

export PAGER=less
export LESSCHARSET='utf-8'

# -i Ignore case when searching
# -N Display line numbers
# -w Temporarily highlights the first "new" line after a forward movement of a full page.
# -z-4 Changes the default scrolling window size of n lines. Negative value is n less than total lines.
# -F Quit if entire file can be displayed on one screen (use -X with this)
# -R Causes raw control characters to be displayed
# -P Custom prompt
# -g Highlight only the match on the particular string from by the last search command, not ALL strings.
export LESS='-g -w -z-4 -R -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
