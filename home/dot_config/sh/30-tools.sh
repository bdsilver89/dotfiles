_shell_name() {
  [ -n "$ZSH_VERSION" ] && { echo zsh; return ; }
  echo bash
}
_sh="$(_shell_name)"

if command -v fzf >/dev/null 2>&1; then
  if command -v bat >/dev/null 2>&1; then
    FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"
  else
    FZF_DEFAULT_OPTS="--preview 'cat {}'"
  fi
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default $FZF_THEME_COLORS"
  eval "$(fzf --"$_sh")"
fi

command -v mise >/dev/null 2>&1 && eval "$(mise activate "$_sh")"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init "$_sh")"
command -v starship >/dev/null 2>&1 && eval "$(starship init "$_sh")"
unset _sh
unset -f _shell_name
