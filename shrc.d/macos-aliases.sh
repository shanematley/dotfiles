if [[ $OSTYPE =~ ^(darwin)+ ]]; then

    # Usage: `mergepdf -o output.pdf input1.pdf input.pdf`
    alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'

fi
