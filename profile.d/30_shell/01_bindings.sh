# Shell key bindings configuration
if [[ "$CURRENT_SHELL" == "zsh" ]] || [[ -n "$ZSH_VERSION" ]]; then
    # Zsh vi mode and keybindings
    bindkey -v
    bindkey "^p" history-search-backward
    bindkey "^n" history-search-forward
    # Note: ^r is handled by fzf integration (see 20_navigation/02_fzf.sh)
elif [[ "$CURRENT_SHELL" == "bash" ]] || [[ -n "$BASH_VERSION" ]]; then
    # Bash vi mode
    set -o vi
fi