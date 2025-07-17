# Zoxide (smart cd) configuration
if command -v zoxide >/dev/null 2>&1; then
    # Shell-specific initialization
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
        eval "$(zoxide init zsh)"
    elif [[ "$CURRENT_SHELL" == "bash" ]]; then
        eval "$(zoxide init bash)"
    fi
fi