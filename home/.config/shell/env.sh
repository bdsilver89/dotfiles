# Moves an existing entry to the front instead of skipping it, so re-running
# after macOS's path_helper restores our order.
_prepend_path() {
    [ -d "$1" ] || return 0
    _rest=":$PATH:"
    while :; do
        case $_rest in
        *":$1:"*) _rest="${_rest%%":$1:"*}:${_rest#*":$1:"}" ;;
        *) break ;;
        esac
    done
    _rest=${_rest#:}
    _rest=${_rest%:}
    PATH="$1${_rest:+:$_rest}"
    unset _rest
}

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

_prepend_path "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
_prepend_path "/opt/homebrew/bin"
_prepend_path "$HOME/bin"
_prepend_path "$HOME/.local/bin"
_prepend_path "$XDG_DATA_HOME/mise/shims"

if [ -d "$HOME/vcpkg" ]; then
    export VCPKG_ROOT="$HOME/vcpkg"
    _prepend_path "$VCPKG_ROOT"
fi

export PATH
unset -f _prepend_path

if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    export VISUAL=nvim
else
    export EDITOR=vim
    export VISUAL=vim
fi
export PAGER=less
export LESS='-FRX'

# Leave CMAKE_COLOR_DIAGNOSTICS unset so compilers detect terminal colors
# automatically and omit escape codes from captured output (e.g. VS Code).
export CMAKE_EXPORT_COMPILE_COMMANDS="ON"
export NINJA_STATUS="[%f/%t %p %e] "
if command -v ninja >/dev/null 2>&1; then
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
    export FZF_DEFAULT_OPTS="--preview 'if [ -d {} ]; then $_fzf_dir_preview; else $_fzf_file_preview; fi' --border=rounded --info=default"
    unset _fzf_file_preview _fzf_dir_preview
fi

if [ -r "$HOME/.config/shell/local.sh" ]; then
    . "$HOME/.config/shell/local.sh"
fi
