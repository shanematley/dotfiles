if [[ $(uname) == Darwin ]]; then
    # pwdf: echoes path of front-most window of Finder
    pwdf ()
        {
        currFolderPath=$( /usr/bin/osascript <<"        EOT"
            tell application "Finder"
                try
                    set currFolder to (folder of the front window as alias)
                on error
                    set currFolder to (path to desktop folder as alias)
                end try
                POSIX path of currFolder
            end tell
        EOT
        )
        echo "$currFolderPath"
    }

    alias cdf='cd "`pwdf`"'
    alias lsf='ls `pwdf`'
    alias llf='ll `pwdf`'
    alias laf='la `pwdf`'
fi
