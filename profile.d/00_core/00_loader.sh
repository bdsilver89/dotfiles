# Universal shell profile loader
# This file provides functions for loading profile.d configurations

# Function to detect current shell
detect_shell() {
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Function to load profile.d configurations
load_profile_configs() {
    local profile_dir="${1:-$HOME/.profile.d}"
    
    if [[ ! -d "$profile_dir" ]]; then
        return 1
    fi
    
    # Load configurations in order: 00_*, 10_*, 20_*, 30_*, 99_*
    local config_file
    if [[ -n "$ZSH_VERSION" ]]; then
        # Zsh glob syntax
        for config_file in "$profile_dir"/**/*.sh(N); do
            [[ -r "$config_file" ]] && source "$config_file"
        done
    else
        # Bash compatible glob
        for config_file in "$profile_dir"/**/*.sh; do
            [[ -r "$config_file" ]] && source "$config_file"
        done
    fi
}

# Export shell detection for use in other modules
export CURRENT_SHELL=$(detect_shell)