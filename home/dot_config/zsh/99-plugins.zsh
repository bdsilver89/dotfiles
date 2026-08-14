ZSH_PLUGINS="$XDG_DATA_HOME/zsh/plugins"

[ -r "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
  && . "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"

[ -r "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
  && . "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
