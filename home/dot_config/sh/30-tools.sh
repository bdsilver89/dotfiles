# .profile pulls this file into dash/ash logins too, and these four tools only
# emit bash and zsh integrations — feeding bash syntax to dash is a hard parse
# error, not a degraded prompt. Empty _sh means "exports only, no eval".
if [ -n "${ZSH_VERSION:-}" ]; then
  _sh=zsh
elif [ -n "${BASH_VERSION:-}" ]; then
  _sh=bash
else
  _sh=""
fi

# SC2089/SC2090: the quotes in --preview are meant to survive as literal text.
# fzf does its own shell-like splitting of FZF_DEFAULT_OPTS, so `bat {}` has to
# reach it still quoted; the array rewrite shellcheck suggests is for arguments
# this shell will expand, which these are not.
# shellcheck disable=SC2089,SC2090
if command -v fzf >/dev/null 2>&1; then
  if command -v bat >/dev/null 2>&1; then
    FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"
  else
    FZF_DEFAULT_OPTS="--preview 'cat {}'"
  fi
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default $FZF_THEME_COLORS"
  if [ -n "$_sh" ]; then eval "$(fzf --"$_sh")"; fi
fi

if [ -n "$_sh" ]; then
  command -v mise >/dev/null 2>&1 && eval "$(mise activate "$_sh")"
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init "$_sh")"
  command -v starship >/dev/null 2>&1 && eval "$(starship init "$_sh")"
fi
unset _sh
