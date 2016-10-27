# From: https://sanctum.geek.nz/cgit/dotfiles.git/tree/sh/shrc.d/rd.sh
#
# Replace the first instance of the first argument string with the second
# argument string in $PWD, and make that the target of the cd builtin. This is
# to emulate a feature of the `cd` builtin in Zsh that I like, but that I think
# should be a separate command rather than overloading `cd`.
#
#     $ pwd
#     /usr/local/bin
#     $ rd local
#     $ pwd
#     /usr/bin
#     $ rd usr opt
#     $ pwd
#     /opt/bin
#
rd() {

    # Check argument count
    case $# in
        1|2) ;;
        *)
            printf >&2 \
                'rd(): Need a string and optionally a replacement\n'
            return 2
            ;;
    esac

    # Set the positional parameters to an option terminator and what will
    # hopefully end up being the substituted directory name
    set -- "$(

        # Current path: e.g. /foo/ayy/bar/ayy
        cur=$PWD
        # Pattern to replace: e.g. ayy
        pat=$1
        # Text with which to replace pattern: e.g. lmao
        # This can be a null string or unset, in order to *remove* the pattern
        rep=$2

        # /foo/
        curtc=${cur%%"$pat"*}
        # /bar/ayy
        curlc=${cur#*"$pat"}
        # /foo/lmao/bar/ayy
        new=${curtc}${rep}${curlc}

        # Check that a substitution resulted in an actual change and that we
        # ended up with a non-null target, or print an error to stderr
        if [ "$cur" = "$curtc" ] || [ -z "$new" ] ; then
            printf >&2 'rd(): Substitution failed\n'
            exit 1
        fi

        # Print the target
        printf '%s\n' "$new"
    )"

    # If the subshell printed nothing, return with failure
    [ -n "$1" ] || return

    # Try to change into the determined directory
    command cd -- "$@"
}
