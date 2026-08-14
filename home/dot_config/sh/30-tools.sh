_shell_name() {
  [ -n "$ZSH_VERSION" ] && { echo zsh; return ; }
  echo bash
}
_sh="$(_shell_name)"

command -v mise >/dev/null 2>&1 && eval "$(mise activate "$_sh")"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init "$_sh")"
command -v starship >/dev/null 2>&1 && eval "$(starship init "$_sh")"
unset _sh
unset -f _shell_name
