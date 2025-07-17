# FZF (Fuzzy Finder) configuration
if command -v fzf >/dev/null 2>&1; then
    # Shell-specific initialization
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
        source <(fzf --zsh)
    elif [[ "$CURRENT_SHELL" == "bash" ]]; then
        eval "$(fzf --bash)"
    fi

    # Universal FZF options
    if command -v bat >/dev/null 2>&1; then
        export FZF_DEFAULT_OPTS="--preview 'bat {}'"
    else
        export FZF_DEFAULT_OPTS="--preview 'cat {}'"
    fi
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default"

    # Universal alias for editing files with fzf
    alias f='$EDITOR "$(fzf)"'
fi