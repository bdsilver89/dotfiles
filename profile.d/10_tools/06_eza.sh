# eza configuration
# Force eza to use XDG config directory on macOS
if command -v asdf >/dev/null 2>&1; then
  export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eza"
fi
