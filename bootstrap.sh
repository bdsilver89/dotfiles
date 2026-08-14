#!/bin/sh
# Bring a machine from zero to a fully applied chezmoi state.
#
#   sh -c "$(curl -fsLS https://raw.githubusercontent.com/brian/dotfiles/main/bootstrap.sh)"
#   ./bootstrap.sh --role headless --theme dracula --work --yes
#   ./bootstrap.sh --source ~/dotfiles-cm        # apply a local worktree
set -eu

REPO="${DOTFILES_REPO:-git@github.com:brian/dotfiles.git}"
SRC=""; ROLE=""; THEME=""; EMAIL=""; WORK=""; EXCLUDE=""; YES=""

# chezmoi keys --promptString/--promptBool by the PROMPT TEXT, not by the data
# key, so these must match home/.chezmoi.toml.tmpl verbatim. Changing a prompt
# there means changing it here and in .github/workflows/ci.yml.
P_ROLE='Machine role (desktop/headless)'
P_THEME='Colour scheme'
P_EMAIL='Git email'
P_WORK='Is this a work machine?'

usage() { sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }
log()   { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

while [ $# -gt 0 ]; do
    case "$1" in
        --source)  SRC="$2";     shift 2 ;;
        --repo)    REPO="$2";    shift 2 ;;
        --role)    ROLE="$2";    shift 2 ;;
        --theme)   THEME="$2";   shift 2 ;;
        --email)   EMAIL="$2";   shift 2 ;;
        --exclude) EXCLUDE="$2"; shift 2 ;;
        --work)    WORK=true;    shift ;;
        --no-work) WORK=false;   shift ;;
        -y|--yes)  YES=1;        shift ;;
        -h|--help) usage 0 ;;
        *) echo "bootstrap: unknown option: $1" >&2; usage 2 ;;
    esac
done

# 1. Prerequisites.
case "$(uname -s)" in
Darwin)
    if ! xcode-select -p >/dev/null 2>&1; then
        log "installing Xcode Command Line Tools - accept the dialog"
        xcode-select --install >/dev/null 2>&1 || true
        while ! xcode-select -p >/dev/null 2>&1; do sleep 5; done
    fi
    ;;
Linux)
    if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
        log "installing git and curl"
        sudo apt-get update -qq
        sudo apt-get install -y -qq git curl
    fi
    # 2. Prime sudo for the apt-get inside the package script, and keep the
    #    timestamp warm for the length of the apply. The keepalive exits with
    #    its parent.
    if [ "$(id -u)" -ne 0 ] && ! sudo -n true 2>/dev/null; then
        sudo -v
        while sudo -n true 2>/dev/null; do
            sleep 50
            kill -0 "$$" 2>/dev/null || exit 0
        done &
    fi
    ;;
*)
    echo "bootstrap: unsupported platform $(uname -s)" >&2; exit 1 ;;
esac

if ! command -v chezmoi >/dev/null 2>&1; then
    log "installing chezmoi"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi
PATH="$HOME/.local/bin:$PATH"; export PATH

# 3. Prompt answers.
#
# `[ -n "$X" ] && set -- ...` would abort the whole script under `set -e`
# whenever X is empty, because the list's exit status is that of the failed
# test. This is the single most common way a `set -eu` script dies silently on
# its happy path. Use `if`.
set -- init --apply
if [ -n "$SRC" ];     then set -- "$@" --source "$SRC"; else set -- "$@" "$REPO"; fi
if [ -n "$ROLE" ];    then set -- "$@" --promptString "$P_ROLE=$ROLE"; fi
if [ -n "$THEME" ];   then set -- "$@" --promptString "$P_THEME=$THEME"; fi
if [ -n "$EMAIL" ];   then set -- "$@" --promptString "$P_EMAIL=$EMAIL"; fi
if [ -n "$WORK" ];    then set -- "$@" --promptBool "$P_WORK=$WORK"; fi
if [ -n "$EXCLUDE" ]; then set -- "$@" --exclude "$EXCLUDE"; fi
if [ -n "$YES" ];     then set -- "$@" --promptDefaults --no-tty --force; fi

log "chezmoi $*"
exec chezmoi "$@"
