# eza configuration
# Force eza to use XDG config directory on macOS
if command -v asdf >/dev/null 2>&1; then
  export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eza"
fi

export EZA_COLORS=" \
  uu=36: \
  uR=31: \
  un=35: \
  gu=37: \
  da=2;34: \
  ur=34: \
  uw=95: \
  ux=36: \
  ue=36: \
  gr=34: \
  gw=35: \
  gx=36: \
  tr=34: \
  tw=35: \
  tx=36: \
  xx=95:"
