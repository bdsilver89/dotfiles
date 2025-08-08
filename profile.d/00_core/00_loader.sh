# Universal shell profile loader
# This file provides functions for loading profile.d configurations

# Prevent multiple sourcing in the same shell session
# Check if we've already loaded for this specific shell PID
_profile_d_var="PROFILE_D_SOURCED_$$"
if eval "[ -n \"\$$_profile_d_var\" ]"; then
    return 0 2>/dev/null || exit 0
fi
eval "export $_profile_d_var=1"
# Keep old variable for compatibility
export PROFILE_D_SOURCED=1

# Function to detect current shell
detect_shell() {
    # First try to use $SHELL if it's set
    if [[ -n "$SHELL" ]]; then
        case "$SHELL" in
            */zsh)
                echo "zsh"
                return
                ;;
            */bash)
                echo "bash"
                return
                ;;
        esac
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

