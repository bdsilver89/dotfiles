# .zshenv sets these for zsh, but bash never reads it, so they must be
# established here too or STARSHIP_CONFIG/MISE_CONFIG_DIR resolve to /starship.toml
# and /mise in every bash session. Idempotent, so double-setting is harmless.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-FRX'
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"
