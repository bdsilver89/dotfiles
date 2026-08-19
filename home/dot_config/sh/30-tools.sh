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
    command -v fzf >/dev/null 2>&1 && eval "$(fzf --$_sh)"
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
        export FZF_DEFAULT_OPTS="--preview 'bat {}'"
    else
        export FZF_DEFAULT_OPTS="--preview 'cat {}'"
    fi
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default"
fi

unset _sh
