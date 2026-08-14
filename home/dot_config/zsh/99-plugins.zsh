ZSH_PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

[ -r "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
  && . "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Must be last: syntax highlighting wraps every widget defined before it.
[ -r "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
  && . "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
