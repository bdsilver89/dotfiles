ZSH_AUTOSUGGEST_STRATEGY=(history completion)

_zsh_plugins="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

for _p in zsh-autosuggestions zsh-syntax-highlighting; do
    [ -r "$_zsh_plugins/$_p/$_p.zsh" ] && . "$_zsh_plugins/$_p/$_p.zsh"
done

(( $+widgets[autosuggest-accept] )) && bindkey '^f' autosuggest-accept

unset _p _zsh_plugins
