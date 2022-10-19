if [[ -n $TERM ]]; then
    autoload -U promptinit; promptinit

    PURE_GIT_UNTRACKED_DIRTY=0
    PURE_ALWAYS_SHOW_USERNAME=1
    PURE_DISPLAY_JOBS=1

    # Use pure prompt if available. It is a submodule of this repo.
    [[ -f /.dockerenv ]] && export PURE_PROMPT_SYMBOL="(Docker) ❯"
    prompt -l 2>/dev/null|grep -qw pure && prompt pure
fi
