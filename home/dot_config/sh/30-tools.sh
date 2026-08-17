if [ -n "${ZSH_VERSION:-}" ]; then
  _sh=zsh
elif [ -n "${BASH_VERSION:-}" ]; then
  _sh=bash
else
  _sh=""
fi

if [ -n "$_sh" ]; then
  command -v mise >/dev/null 2>&1 && eval "$(mise activate "$_sh")"
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init "$_sh")"
  command -v starship >/dev/null 2>&1 && eval "$(starship init "$_sh")"
fi
unset _sh
