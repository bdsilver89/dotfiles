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
    if command -v fzf >/dev/null 2>&1; then
        # --zsh/--bash flags need fzf >=0.48; older fzf lacks them. Try
        # silently and only eval on success, so a stale fzf earlier on
        # PATH (e.g. distro package ahead of the mise shim) can't error.
        _fzf_init=$(fzf --"$_sh" 2>/dev/null) && eval "$_fzf_init"
        unset _fzf_init
    fi
fi

if command -v ninja >/dev/null 2>&1; then
    if [ "$(ninja --version | cut -d '.' -f 2)" -ge "10" ]; then
        export NINJA_STATUS=$(echo -e "[%f/%t %p %e] ")
    fi
    export CMAKE_GENERATOR="Ninja"
    export CONAN_CMAKE_GENERATOR="Ninja"
fi

if command -v fzf >/dev/null 2>&1; then
    if command -v bat >/dev/null 2>&1; then
        _fzf_file_preview='bat {}'
    else
        _fzf_file_preview='cat {}'
    fi
    if command -v eza >/dev/null 2>&1; then
        _fzf_dir_preview='eza --color=always --icons=always --git -la {}'
    else
        _fzf_dir_preview='ls -la {}'
    fi
    export FZF_DEFAULT_OPTS="--preview 'if [ -d {} ]; then $_fzf_dir_preview; else $_fzf_file_preview; fi'"
    unset _fzf_file_preview _fzf_dir_preview
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default"
fi

unset _sh
