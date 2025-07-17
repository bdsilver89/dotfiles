# Shell key bindings configuration
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    # Zsh vi mode and keybindings
    bindkey -v
    bindkey "^p" history-search-backward
    bindkey "^n" history-search-forward
    bindkey "^r" history-incremental-search-backward
elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    # Bash vi mode
    set -o vi
fi