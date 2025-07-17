# Shell history configuration
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    # Zsh history settings
    HISTSIZE=5000
    HISTFILE=~/.zsh_history
    HISTDUP=erase
    setopt appendhistory
    setopt sharehistory
    setopt hist_ignore_space
    setopt hist_ignore_all_dups
elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    # Bash history settings (if any specific ones are needed)
    export HISTSIZE=5000
    export HISTFILESIZE=10000
    export HISTCONTROL=ignoredups:erasedups
fi