# FZF (Fuzzy Finder) configuration
if command -v fzf >/dev/null 2>&1; then
    # Universal FZF options (set before loading shell integration)
    if command -v bat >/dev/null 2>&1; then
        export FZF_DEFAULT_OPTS="--preview 'bat {}'"
    else
        export FZF_DEFAULT_OPTS="--preview 'cat {}'"
    fi
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default"

    # Shell-specific initialization
    # Check which shell we're actually running in (not just $SHELL variable)
    if [ -n "$ZSH_VERSION" ]; then
        # We're in zsh - load fzf zsh integration
        eval "$(fzf --zsh)"
    elif [ -n "$BASH_VERSION" ]; then
        # We're in bash - load fzf bash integration
        eval "$(fzf --bash)"
    fi

    # Universal alias for editing files with fzf
    alias f='$EDITOR "$(fzf)"'
fi