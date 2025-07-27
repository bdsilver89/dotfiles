# Universal shell profile loader
# This file provides functions for loading profile.d configurations

if [ -n "$PROFILE_D_SOURCED" ]; then
    return
fi
export PROFILE_D_SOURCED=1

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

# Export shell detection for use in other modules
export CURRENT_SHELL=$(detect_shell)

# Function to load profile.d configurations
load_profile_configs() {
    local profile_dir="${1:-$HOME/.profile.d}"

    if [[ ! -d "$profile_dir" ]]; then
        return 1
    fi

    # Load configurations in order: 00_*, 10_*, 20_*, 30_*, 99_*
    for dir in "$profile_dir"/*/; do
        if [ -d "$dir" ]; then
            for config in "$dir"*.sh; do
                if [ -f "$config" ] && [ -r "$config" ]; then
                    if [[ "$config" != *"/00_core/00_loader.sh" ]]; then
                        source "$config"
                    fi
                fi
            done
        fi
    done
}

load_profile_configs

