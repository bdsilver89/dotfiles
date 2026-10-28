if [ -n "${ZSH_VERSION:-}" ]; then
    _sh=zsh
elif [ -n "${BASH_VERSION:-}" ]; then
    _sh=bash
else
    _sh=""
fi

if [ -n "$_sh" ]; then
    command -v mise >/dev/null 2>&1 && eval "$(mise activate "$_sh")"
    command -v direnv >/dev/null 2>&1 && eval "$(direnv hook "$_sh")"
    command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init "$_sh")"
    command -v starship >/dev/null 2>&1 && eval "$(starship init "$_sh")"
    if command -v fzf >/dev/null 2>&1; then
        # --zsh/--bash flags need fzf >=0.48; older fzf lacks them. Try
        # silently and only eval on success, so a stale fzf earlier on
        # PATH (e.g. distro package ahead of the mise shim) can't error.
        _fzf_init=$(fzf --"$_sh" 2>/dev/null) && eval "$_fzf_init"
        unset _fzf_init
    fi
fi

unset _sh
