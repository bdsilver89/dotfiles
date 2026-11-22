#!/usr/bin/env bash

set -euo pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

DOTFILES=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
OS=$(uname -s)

# Prompt about conflicting files unless --non-interactive / DOTFILES_NONINTERACTIVE=1
# is set or stdin is not a terminal; then conflicts fail the install.
INTERACTIVE=1
[[ "${DOTFILES_NONINTERACTIVE-0}" == "1" || ! -t 0 ]] && INTERACTIVE=0
for arg in "$@"; do
    case "$arg" in
        -n|--non-interactive) INTERACTIVE=0 ;;
        -h|--help) echo "Usage: $0 [-n|--non-interactive]"; exit 0 ;;
        *) echo "❌  Unknown option: $arg" >&2; exit 1 ;;
    esac
done

case "$OS" in
    Darwin|Linux) ;;
    *) echo "❌  Unsupported OS: $OS" >&2; exit 1 ;;
esac

for cmd in curl git; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌  $cmd is required but not installed." >&2
        exit 1
    fi
done

# Bootstrap Mise through its official checksum-verifying installer when missing.
if command -v mise >/dev/null 2>&1; then
    MISE=$(command -v mise)
else
    echo "🛠   Installing Mise..."
    MISE="$HOME/.local/bin/mise"
    mkdir -p "$HOME/.local/bin"
    installer="$(curl -fsSL https://mise.run)"
    MISE_INSTALL_PATH="$MISE" MISE_INSTALL_HELP=0 sh -c "$installer"
fi

"$MISE" trust --quiet "$DOTFILES/mise.toml"

# Link dotfiles, including the global Mise configuration, without forcing conflicts.
echo
echo "🛠   Creating symlinks..."
if ! out=$("$MISE" --cd "$DOTFILES" dot apply --yes 2>&1); then
    echo "$out" >&2
    [[ "$INTERACTIVE" == "1" ]] || exit 1

    # Existing files mise refused to overwrite are listed as indented paths.
    conflicts=$(sed -n 's|^  \(~/.*\)$|\1|p; s|^  \(/.*\)$|\1|p' <<<"$out")
    [[ -n "$conflicts" ]] || exit 1

    skipped=0
    echo
    while IFS= read -r file; do
        path="${file/#\~/$HOME}"
        while true; do
            read -r -p "$file exists: [b]ackup, [r]eplace, [s]kip, [q]uit? " choice </dev/tty
            case "$choice" in
                b|B) mv -- "$path" "$path.bak.$(date +%Y%m%d%H%M%S)"; echo "    backed up"; break ;;
                r|R) rm -rf -- "$path"; echo "    removed"; break ;;
                s|S) skipped=1; break ;;
                q|Q) echo "Aborted."; exit 1 ;;
            esac
        done
    done <<<"$conflicts"

    # Skipped files still conflict, so a failed retry is only a warning then.
    if ! "$MISE" --cd "$DOTFILES" dot apply --yes; then
        [[ "$skipped" == "1" ]] || exit 1
        echo "⚠️   Skipped files were not linked; continuing." >&2
    fi
else
    [[ -z "$out" ]] || echo "$out"
fi
echo "🛠   Creating symlinks... done."

# Run after linking so the global config's [bootstrap.packages] and [tools] are loaded.
# Reconcile declared state without upgrades, repo updates, or local project builds.
echo
echo "🛠   Applying Mise setup..."
"$MISE" --cd "$DOTFILES" bootstrap --yes --skip-dirty --only packages,repos,tools
echo "🛠   Applying Mise setup... done."
