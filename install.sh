#!/usr/bin/env bash

set -euo pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

DOTFILES=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
OS=$(uname -s)

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
"$MISE" --cd "$DOTFILES" dot apply --yes
echo "🛠   Creating symlinks... done."

# Run after linking so the global config's [bootstrap.packages] and [tools] are loaded.
# Reconcile declared state without upgrades, repo updates, or local project builds.
echo
echo "🛠   Applying Mise setup..."
"$MISE" --cd "$DOTFILES" bootstrap --yes --skip-dirty --only packages,repos,tools
echo "🛠   Applying Mise setup... done."
