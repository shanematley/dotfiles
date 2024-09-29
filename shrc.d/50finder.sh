#!/bin/bash

if osis Darwin; then
    # Go to the directory that is shown in the top-most Finder window
    function cdf() {
        local finderPath
        finderPath=$(osascript -e 'try
            tell application "Finder" to set the source_folder to (folder of the front window) as alias
        on error
            tell application "Finder" to set source_folder to insertion location as alias
        end try
        return POSIX path of source_folder as string')
        cd "$finderPath" || return
    }

    # Select the files passed to this function in Finder
    function sel() {
        local workingD="$PWD"
        local applescript='set theFiles to {}'
        local LINE
        local filez
        while read -r LINE; do
            local aLine="${LINE}"
            if [[ -n "$aLine" && "$aLine" != "" ]]; then
                filez="${workingD}/${aLine}"
                applescript+="
                try
                    set aFile to POSIX file \"$filez\"
                    set testFile to aFile as alias
                    if testFile is not missing value then
                            set end of theFiles to aFile
                    end if
                    (*      on error errMsg
                        display dialog errMsg
                    *)
                end try"
            fi
        done
        applescript+='
            if (count of theFiles) > 0 then
                    tell application "Finder"
                            select theFiles
                            activate
                    end tell
            end if
            return'
        echo "$applescript" | osascript -
    }
fi