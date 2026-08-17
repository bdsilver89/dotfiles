_prepend_path() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) [ -d "$1" ] && PATH="$1:$PATH" ;;
    esac
}

_prepend_path "$HOME/.local/bin"
_prepend_path "$HOME/bin"
[ -d /opt/homebrew/bin ] && _prepend_path "/opt/homebrew/bin"

export PATH
unset -f _prepend_path
