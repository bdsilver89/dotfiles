# Universal shell profile loader
# This file provides functions for loading profile.d configurations

# Prevent multiple sourcing in the same shell session.
#
# The guard is deliberately NOT exported. It used to be `export
# PROFILE_D_SOURCED_$$`, but $$ survives `exec` while shell state does not:
# Zed's shell integration re-execs zsh in the same process, so the second
# .zshrc pass saw the guard, returned early, and left the default prompt.
# A plain variable dies with the old shell image, which is exactly the scope
# we want -- "already loaded in this shell instance".
if [ -n "$PROFILE_D_SOURCED_THIS_SHELL" ]; then
    return 0 2>/dev/null || exit 0
fi
PROFILE_D_SOURCED_THIS_SHELL=1
# Keep old variable for compatibility
export PROFILE_D_SOURCED=1

# Function to detect current shell
detect_shell() {
    # Prefer the shell actually running this file. $SHELL is the login shell
    # recorded in /etc/passwd, and some terminals (Zed under WSL) launch zsh
    # without it, which used to leave the prompt unconfigured.
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
        return
    fi
    if [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
        return
    fi

    # Fall back to $SHELL if the running shell can't identify itself
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

