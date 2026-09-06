#!/usr/bin/env bash
set -euo pipefail

# Written for bash 3.2 so it runs on stock macOS: no associative arrays,
# no mapfile, no ${var,,}.

# =============================================================================
# Globals
# =============================================================================

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/bdsilver89/dotfiles.git}"
REPO_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

START_TIME=$SECONDS

ROLE=""                 # desktop | headless
CONFLICT_MODE="prompt"  # prompt | backup | skip | overwrite
CONFLICT_ALL=""         # set by the [B]/[O]/[S] menu choices
RESOLUTION=""           # out-param of resolve_conflict
BAK=""                  # out-param of backup_path
ONLY=""                 # run a single phase
DRY_RUN=0
VERBOSE=0

OS=""
FAMILY=""
PKG=""
DISTRO_ID=""

N_LINKED=0
N_UNCHANGED=0
N_BACKED_UP=0
N_WARNINGS=0

# =============================================================================
# Logging
# =============================================================================
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_DIM=$'\033[2m'
    C_RED=$'\033[31m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_BLUE=$'\033[34m'
else
    C_RESET=""
    C_BOLD=""
    C_DIM=""
    C_RED=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
fi
GUTTER=11

# Colour is emitted before the padding so escapes do not count toward %*s.
_emit() {
    local color="$1"
    local verb="$2"
    shift 2
    printf '%s%*s%s %s\n' "$color" "$GUTTER" "$verb" "$C_RESET" "$*"
}

banner() {
    printf '\n%sdotfiles%s  %s\n' "$C_BOLD" "$C_RESET" "$*"
}

phase() { printf '\n%s%*s%s\n' "$C_BOLD" "$GUTTER" "$1" "$C_RESET"; }

say()  { _emit "$C_GREEN" "$@"; }
note() { _emit "$C_DIM"   "$@"; }
warn() { N_WARNINGS=$((N_WARNINGS + 1)); _emit "$C_YELLOW" "Warning" "$*" >&2; }
die()  { _emit "$C_RED" "Error" "$*" >&2; exit 1; }

vsay() { [ "$VERBOSE" -eq 1 ] && note "$@"; return 0; }

# Continuation line for multi-line detail, aligned past the gutter.
cont() { printf '%*s %s\n' "$GUTTER" "" "$*"; }

tilde() { printf '%s\n' "${1/#$HOME/~}"; }

# =============================================================================
# Utils
# =============================================================================
# In dry-run the per-command narration is redundant with the Linked/Backed up
# lines the callers already print, so it is verbose-only.
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        vsay "Would run" "$*"
        return 0
    fi
    "$@"
}

quietly() {
    if [ "$DRY_RUN" -eq 1 ]; then
        vsay "Would run" "$*"
        return 0
    fi

    local log rc=0
    log="$(mktemp)"
    "$@" >"$log" 2>&1 || rc=$?

    # Replays output but does not warn: the caller decides whether a non-zero
    # exit is worth reporting, so failures are not counted twice.
    if [ "$rc" -ne 0 ]; then
        tail -n 20 "$log" | while IFS= read -r line; do cont "$C_DIM$line$C_RESET"; done
    elif [ "$VERBOSE" -eq 1 ]; then
        while IFS= read -r line; do cont "$C_DIM$line$C_RESET"; done <"$log"
    fi

    rm -f "$log"
    return "$rc"
}

# Silent in dry-run: mkdir chatter would drown the interesting lines.
ensure_dir() {
    [ "$DRY_RUN" -eq 1 ] && return 0
    mkdir -p "$1"
}

have() { command -v "$1" >/dev/null 2>&1; }

summarize_list() {
    local max="$1"; shift
    local n=$#
    if [ "$n" -le "$max" ]; then echo "$*"; return; fi
    local head=""
    while [ "$max" -gt 0 ] && [ $# -gt 0 ]; do
        head="$head $1"; shift; max=$((max - 1))
    done
    echo "${head# } and $# more"
}

plural() {
    [ "$1" -eq 1 ] && echo "$1 $2" || echo "$1 $2s"
}

# =============================================================================
# Platform
# =============================================================================
detect_platform() {
    case "$(uname -s)" in
        Darwin) OS="darwin"; FAMILY="darwin"; PKG="brew" ;;
        Linux) OS="linux" ;;
        *) die "unsupported OS: $(uname -s). Windows uses install.ps1." ;;
    esac

    if [ "$OS" = "linux" ]; then
        [ -r /etc/os-release ] || die "cannot read /etc/os-release"
        . /etc/os-release
        DISTRO_ID="${ID:-}"
        local like="${ID_LIKE:-}"

        case " $DISTRO_ID $like " in
            *" debian "*|*" ubuntu "*) FAMILY="debian"; PKG="apt" ;;
            *" rhel "*|*" fedora "*)   FAMILY="rhel";   PKG="dnf" ;;
            *)
                case "$DISTRO_ID" in
                    debian|ubuntu|linuxmint|pop|raspbian) FAMILY="debian"; PKG="apt" ;;
                    fedora|rhel|centos|rocky|almalinux|ol) FAMILY="rhel"; PKG="dnf" ;;
                    *) die "unsupported distro: ${DISTRO_ID:-unknown}" ;;
                esac
                ;;
        esac
    fi
}

is_rhel_rebuild() {
    [ "$FAMILY" = "rhel" ] && [ "$DISTRO_ID" != "fedora" ]
}

is_wsl() {
    [ -n "${WSL_DISTRO_NAME:-}${WSL_INTEROP:-}" ]
}

detect_role() {
    [ -n "$ROLE" ] && return 0
    # WSL reports a display under WSLg but has no use for native GUI packages.
    if is_wsl; then
        ROLE="headless"
    elif [ "$OS" = "darwin" ] || [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
        ROLE="desktop"
    else
        ROLE="headless"
    fi
    return 0
}

# =============================================================================
# Bootstrap
# =============================================================================

# Absolute path to this script, or empty when piped from curl.
script_path() {
    local src="${BASH_SOURCE[0]:-}"
    case "$src" in
        ""|bash|/dev/fd/*|/proc/self/fd/*) return 0 ;;
    esac
    [ -f "$src" ] || return 0
    ( cd "$(dirname "$src")" && printf '%s/%s\n' "$PWD" "$(basename "$src")" )
}

install_git() {
    case "$PKG" in
        brew)
            xcode-select -p >/dev/null 2>&1 || run xcode-select --install || true
            have git || die "git unavailable; run xcode-select --install and retry"
            ;;
        apt) quietly sudo apt-get update && quietly sudo apt-get install -y git || die "could not install git" ;;
        dnf) quietly sudo dnf install -y git || die "could not install git" ;;
    esac
}

bootstrap_repo() {
    local self
    self="$(script_path)"

    if [ -n "$self" ] && [ -d "$(dirname "$self")/home" ]; then
        REPO_DIR="$(dirname "$self")"
        return 0
    fi

    phase "Bootstrap"
    have git || install_git

    if [ -d "$REPO_DIR/.git" ]; then
        quietly git -C "$REPO_DIR" pull --ff-only || warn "pull failed, using working tree as-is"
        say "Updated" "$(tilde "$REPO_DIR")"
    else
        quietly git clone "$REPO_URL" "$REPO_DIR" || die "clone failed"
        say "Cloned" "$REPO_URL"
    fi

    [ "$DRY_RUN" -eq 1 ] && return 0

    say "Restarted" "from $(tilde "$REPO_DIR")"
    exec bash "$REPO_DIR/install.sh" "$@"
}

# =============================================================================
# Packages
# =============================================================================

PKGS_CORE="git tmux fzf ripgrep bat eza zoxide jq zsh"

# The mise tool list is not here: it lives in home/.config/mise/config.toml,
# which is symlinked into place. Only the one platform conditional is generated,
# by write_mise_platform_config below.

# macOS-only packages live in ./Brewfile, applied with `brew bundle`.
PKGS_DESKTOP_LINUX="alacritty"

GH_EXTENSIONS="dlvhdr/gh-dash dlvhdr/gh-enhance github/gh-stack"

# name|command|url
VENDOR="claude-code|claude|https://claude.ai/install.sh
rtk|rtk|https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh"

# name|url|ref
ZSH_PLUGINS="zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git|v0.7.1
zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git|0.8.0"

CATPPUCCIN_TMUX_VERSION="v2.3.0"
VIM_TMUX_NAVIGATOR_REF="master"

# eza is not in EPEL, so the RHEL rebuilds get it from mise instead.
pkg_skipped() {
    case "$1" in
        eza) is_rhel_rebuild ;;
        *)   return 1 ;;
    esac
}

pkg_available() {
    case "$PKG" in
        apt) apt-cache show "$1" >/dev/null 2>&1 ;;
        dnf) dnf info "$1" >/dev/null 2>&1 ;;
        *)   return 0 ;;
    esac
}

# Probe before installing: one package missing from a repo would otherwise fail
# the whole transaction, which varies a lot across the RHEL rebuilds.
available_packages() {
    local p out="" missing=""
    for p in "$@"; do
        if pkg_available "$p"; then
            out="$out $p"
        else
            missing="$missing $p"
        fi
    done
    [ -n "$missing" ] && warn "not in any repo, skipping:$missing"
    echo "${out# }"
}

resolved_core() {
    local p out=""
    for p in $PKGS_CORE; do
        pkg_skipped "$p" && continue
        out="$out $p"
    done
    echo "${out# }"
}

install_packages() {
    phase "Packages"
    case "$PKG" in
        brew) packages_darwin ;;
        apt)  packages_debian ;;
        dnf)  packages_rhel ;;
    esac
}

packages_darwin() {
    if have brew; then
        vsay "Present" "homebrew"
    else
        say "Installing" "homebrew"
        quietly /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # The installer cannot change our PATH, so load its shellenv by hand.
        local prefix
        for prefix in /opt/homebrew /usr/local; do
            [ -x "$prefix/bin/brew" ] || continue
            eval "$("$prefix/bin/brew" shellenv)"
            break
        done
        have brew || die "brew still not on PATH after install"
        say "Installed" "homebrew"
    fi

    local core
    core="$(resolved_core)"
    if quietly brew install $core; then
        say "Installed" "$(summarize_list 8 $core)"
    else
        warn "brew install failed"
    fi

    # Brewfile is casks only today, so headless skips it. If mac-only formulae
    # are ever added there, this needs to run in both roles.
    if [ "$ROLE" != "desktop" ]; then
        vsay "Skipped" "Brewfile (headless)"
    elif quietly env HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file="$REPO_DIR/Brewfile"; then
        say "Installed" "Brewfile"
    else
        warn "brew bundle failed"
    fi
    return 0
}

packages_debian() {
    local core
    quietly sudo apt-get update || warn "apt-get update failed"
    core="$(available_packages $(resolved_core))"

    if quietly sudo apt-get install -y $core; then
        say "Installed" "$(summarize_list 8 $core)"
    else
        warn "apt-get install failed"
    fi

    if [ "$ROLE" = "desktop" ] && [ -n "$PKGS_DESKTOP_LINUX" ]; then
        if quietly sudo apt-get install -y $(available_packages $PKGS_DESKTOP_LINUX); then
            say "Installed" "$PKGS_DESKTOP_LINUX"
        else
            warn "desktop package install failed"
        fi
    fi

    # Debian renames these binaries; newer releases ship /usr/bin/fd directly,
    # so neither link is guaranteed.
    ensure_dir "$HOME/.local/bin"
    if [ -x /usr/bin/batcat ]; then
        run ln -sf /usr/bin/batcat "$HOME/.local/bin/bat" && say "Linked" "~/.local/bin/bat"
    fi
    if [ -x /usr/bin/fdfind ]; then
        run ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd" && say "Linked" "~/.local/bin/fd"
    fi
    return 0
}

packages_rhel() {
    if is_rhel_rebuild; then
        # Most of PKGS_CORE lives in EPEL and several EPEL packages need CRB.
        # Repo names differ per rebuild, so failures here are not fatal. gh no
        # longer needs its own repo here: it comes from mise.
        quietly sudo dnf install -y dnf-plugins-core || warn "dnf-plugins-core failed"
        rpm -q epel-release >/dev/null 2>&1 || \
            quietly sudo dnf install -y \
                "https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm"
        quietly sudo dnf config-manager --set-enabled crb || true
        say "Enabled" "EPEL and CRB"
    fi

    local core
    core="$(available_packages $(resolved_core))"
    if quietly sudo dnf install -y $core; then
        say "Installed" "$(summarize_list 8 $core)"
    else
        warn "dnf install failed"
    fi
    is_rhel_rebuild && vsay "Deferred" "eza to mise (not in EPEL)"

    if [ "$ROLE" = "desktop" ] && [ -n "$PKGS_DESKTOP_LINUX" ]; then
        if quietly sudo dnf install -y $(available_packages $PKGS_DESKTOP_LINUX); then
            say "Installed" "$PKGS_DESKTOP_LINUX"
        else
            warn "desktop package install failed"
        fi
    fi
    return 0
}

# =============================================================================
# mise
# =============================================================================

install_mise() {
    phase "mise"

    # mise's own installer is the only path that behaves the same on macOS,
    # Debian and RHEL; the distro packages are absent or stale.
    if [ -x "$HOME/.local/bin/mise" ]; then
        vsay "Present" "mise"
    elif quietly env MISE_INSTALL_PATH="$HOME/.local/bin/mise" \
        sh -c 'curl -fsSL https://mise.run | sh'
    then
        say "Installed" "mise"
    else
        warn "mise install failed"
    fi

    export PATH="$HOME/.local/bin:$PATH"
    have mise || { warn "mise unavailable, skipping"; return 0; }

    write_mise_platform_config

    # The tool list comes from ~/.config/mise/config.toml, symlinked by the
    # links phase, so there is nothing to pass here.
    if quietly mise install; then
        say "Installed" "mise tools"
    else
        warn "mise install reported failures"
    fi
    return 0
}

# The one thing the tracked config.toml cannot express. eza has no EPEL package,
# and mise can only build it from source (cargo:eza), so it is worth doing on
# the RHEL rebuilds and not worth it anywhere else. Written as a conf.d drop-in,
# which mise merges with config.toml.
write_mise_platform_config() {
    local dest="$XDG_CONFIG_HOME/mise/conf.d/00-platform.toml"

    if ! is_rhel_rebuild; then
        [ -e "$dest" ] && run rm -f "$dest"
        return 0
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        note "Would write" "$(tilde "$dest")"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    cat >"$dest" <<'''EOF'''
# Generated by install.sh. eza has no EPEL package on the RHEL rebuilds.
[tools]
eza = "latest"
EOF
    say "Wrote" "$(tilde "$dest")"
}

# =============================================================================
# Symlinks
# =============================================================================

LINKS=()

add_link() { LINKS+=("$1|${2:-$1}"); }

# Link the directory itself. Anything written into it lands in the repo, so
# only for directories with no machine-local content.
add_tree() { add_link "$1"; }

# Link each file, recreating the repo's directory structure as real
# directories. The safest granularity: live content can coexist at any depth.
# For directories that hold generated state or a whole project of their own
# (~/.pi's sessions and auth, ~/.config/opencode's npm tree, nvim's pack lock).
add_files() {
    local rel="$1" root="$REPO_DIR/home/$1" f
    if [ ! -d "$root" ]; then
        warn "missing in repo: home/$rel"
        return 0
    fi
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        add_link "${f#$REPO_DIR/home/}"
    done <<EOF
$(find "$root" \( -name node_modules -o -name .git \) -prune -o \
       -type f ! -name .DS_Store ! -name .gitignore -print)
EOF
}

# Link each entry, leaving the directory itself real, so machine-local files
# (alacritty machine.toml, wezterm machine.lua, mise conf.d) sit beside the
# links and never enter the repo. Adding a file to one of these in the repo
# needs another --only=links run.
add_entries() {
    local rel="$1" f name
    for f in "$REPO_DIR/home/$rel"/* "$REPO_DIR/home/$rel"/.[!.]*; do
        [ -e "$f" ] || continue
        name="$(basename "$f")"
        case "$name" in
            .DS_Store|.gitignore) continue ;;
        esac
        add_link "$rel/$name"
    done
}

build_link_map() {
    LINKS=()
    local f

    for f in .bash_profile .bashrc .profile .zshenv .zshrc .vimrc .tmux.conf .gitconfig; do
        add_link "$f"
    done

    # Directories the repo owns outright.
    for f in ghostty workmux zsh; do
        add_tree ".config/$f"
    done

    # Machine-local overrides live in these: alacritty machine.toml,
    # wezterm machine.lua, mise conf.d/*.toml.
    add_entries ".config/alacritty"
    add_entries ".config/wezterm"
    add_entries ".config/mise"

    # These hold live content the repo does not track, at varying depths:
    # nvim's pack lock and notes, a machine-local 30-tools.sh, opencode's own
    # npm project, and ~/.pi's auth, sessions and skills.
    add_files ".config/nvim"
    add_files ".config/sh"
    add_files ".config/tmux"
    add_files ".config/opencode"
    add_files ".pi"

    # .config itself is shared, so single files in it are linked individually.
    add_link ".config/starship.toml"

    # ~/.local/bin is shared with brew, mise and vendor shims.
    add_entries ".local/bin"

    add_tree ".agents/skills"
}

# Adjacent, like the old bootstrap.sh: the backup sits next to what it replaced
# instead of in a directory you have to go find. Sets BAK rather than echoing,
# so log output cannot end up captured as the path.
backup_path() {
    local dst="$HOME/$1"
    BAK="$HOME/$1.backup"
    [ -e "$BAK" ] && BAK="$BAK.$(date +%Y%m%d-%H%M%S)"
    run mv "$dst" "$BAK"
}

# -r is not enough: /dev/tty can exist and still fail to open (no controlling
# terminal), which is exactly the case under a pipeline or a CI runner.
has_tty() {
    { : >/dev/tty; } 2>/dev/null
}

same_content() {
    if [ -d "$1" ] && [ -d "$2" ]; then
        diff -rq "$1" "$2" >/dev/null 2>&1
    elif [ -f "$1" ] && [ -f "$2" ]; then
        cmp -s "$1" "$2"
    else
        return 1
    fi
}

# Sets RESOLUTION rather than echoing: a $() subshell would discard CONFLICT_ALL.
resolve_conflict() {
    local rel="$1" src="$2" dst="$HOME/$1" kind reply

    if [ -n "$CONFLICT_ALL" ]; then RESOLUTION="$CONFLICT_ALL"; return 0; fi
    if [ "$CONFLICT_MODE" != "prompt" ]; then RESOLUTION="$CONFLICT_MODE"; return 0; fi
    has_tty || { RESOLUTION="backup"; return 0; }

    if [ -L "$dst" ]; then kind="symlink -> $(readlink "$dst")"
    elif [ -d "$dst" ]; then kind="directory"
    else kind="file"; fi

    while :; do
        {
            printf '\n%*s %s~/%s%s\n' "$GUTTER" "Conflict" "$C_BOLD" "$rel" "$C_RESET"
            printf '%*s exists as a %s\n' "$GUTTER" "" "$kind"
            printf '%*s  b  back up to ~/%s.backup\n' "$GUTTER" "" "$rel"
            printf '%*s  o  overwrite               s  skip\n' "$GUTTER" ""
            printf '%*s  d  show diff               q  quit\n' "$GUTTER" ""
            printf '%*s  B / O / S  same for all remaining\n' "$GUTTER" ""
            printf '%*s > ' "$GUTTER" ""
        } >/dev/tty

        # Single keypress, no Enter, as the old bootstrap.sh did.
        read -r -n 1 reply </dev/tty || { RESOLUTION="backup"; return 0; }
        printf '\n' >/dev/tty

        case "$reply" in
            b) RESOLUTION="backup"; return 0 ;;
            o) RESOLUTION="overwrite"; return 0 ;;
            s) RESOLUTION="skip"; return 0 ;;
            B) CONFLICT_ALL="backup"; RESOLUTION="backup"; return 0 ;;
            O) CONFLICT_ALL="overwrite"; RESOLUTION="overwrite"; return 0 ;;
            S) CONFLICT_ALL="skip"; RESOLUTION="skip"; return 0 ;;
            q) RESOLUTION="quit"; return 0 ;;
            d)
                local out
                if [ -d "$dst" ] || [ -d "$src" ]; then
                    out="$(diff -rq "$dst" "$src" 2>&1 || true)"
                else
                    out="$(diff -u "$dst" "$src" 2>&1 || true)"
                fi
                if [ -z "$out" ]; then
                    printf '%*s (no differences)\n' "$GUTTER" "" >/dev/tty
                else
                    printf '%s\n' "$out" | head -n 60 >/dev/tty
                    [ "$(printf '%s\n' "$out" | wc -l)" -gt 60 ] &&
                        printf '%*s ... truncated\n' "$GUTTER" "" >/dev/tty
                fi
                ;;
            *) printf '%*s unrecognised choice\n' "$GUTTER" "" >/dev/tty ;;
        esac
    done
}

link_one() {
    local srcrel="$1" rel="$2"
    local src="$REPO_DIR/home/$srcrel" dst="$HOME/$rel" bak=""

    [ -e "$src" ] || { warn "missing in repo: home/$srcrel"; return 0; }

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        N_UNCHANGED=$((N_UNCHANGED + 1))
        vsay "Unchanged" "~/$rel"
        return 0
    fi

    # Same bytes as the repo copy is not a conflict worth asking about: the
    # content is not lost by replacing it, it is what we are linking to.
    if { [ -e "$dst" ] && [ ! -L "$dst" ]; } && same_content "$src" "$dst"; then
        run rm -rf "$dst"
        ensure_dir "$(dirname "$dst")"
        run ln -s "$src" "$dst"
        N_LINKED=$((N_LINKED + 1))
        vsay "Linked" "~/$rel (was identical)"
        return 0
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        resolve_conflict "$rel" "$src"
        case "$RESOLUTION" in
            quit) die "aborted at ~/$rel" ;;
            skip) N_UNCHANGED=$((N_UNCHANGED + 1)); vsay "Skipped" "~/$rel"; return 0 ;;
            backup) backup_path "$rel"; bak="$BAK" ;;
            overwrite) run rm -rf "$dst" ;;
        esac
    fi

    ensure_dir "$(dirname "$dst")"
    run ln -s "$src" "$dst"
    N_LINKED=$((N_LINKED + 1))

    if [ -n "$bak" ]; then
        N_BACKED_UP=$((N_BACKED_UP + 1))
        say "Backed up" "$(tilde "$bak")"
    else
        say "Linked" "~/$rel"
    fi
    return 0
}

link_dotfiles() {
    phase "Linking"
    build_link_map

    local record src dst
    for record in "${LINKS[@]}"; do
        src="${record%%|*}"
        dst="${record#*|}"
        link_one "$src" "$dst"
    done

    write_alacritty_machine_config

    if [ "$N_LINKED" -eq 0 ]; then
        note "Unchanged" "$(plural "$N_UNCHANGED" file) already linked"
    fi
    return 0
}

# alacritty.toml imports machine.toml; seeded once so hand edits survive.
write_alacritty_machine_config() {
    local dest="$XDG_CONFIG_HOME/alacritty/machine.toml" size

    [ -e "$dest" ] && return 0
    [ "$OS" = "darwin" ] && size="13.0" || size="11.0"

    if [ "$DRY_RUN" -eq 1 ]; then
        note "Would seed" "$(tilde "$dest")"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    cat >"$dest" <<EOF
# Per-machine overrides. Not tracked; edit freely.
[font]
normal = { family = "JetBrains Mono" }
size = $size
EOF
    say "Seeded" "$(tilde "$dest")"
}

# =============================================================================
# Externals
# =============================================================================

fetch_externals() {
    phase "Externals"

    local tmux_data="$XDG_DATA_HOME/tmux"
    ensure_dir "$tmux_data/plugins"

    local catppuccin="$tmux_data/plugins/catppuccin"
    local stamp="$catppuccin/.version"

    if [ -f "$stamp" ] && [ "$(cat "$stamp" 2>/dev/null)" = "$CATPPUCCIN_TMUX_VERSION" ]; then
        vsay "Current" "catppuccin/tmux $CATPPUCCIN_TMUX_VERSION"
    elif [ "$DRY_RUN" -eq 1 ]; then
        note "Would fetch" "catppuccin/tmux $CATPPUCCIN_TMUX_VERSION"
    else
        local tmp
        tmp="$(mktemp -d)"
        if curl -fsSL \
            "https://github.com/catppuccin/tmux/archive/refs/tags/$CATPPUCCIN_TMUX_VERSION.tar.gz" \
            | tar -xz -C "$tmp" --strip-components=1
        then
            rm -rf "$catppuccin"
            mv "$tmp" "$catppuccin"
            echo "$CATPPUCCIN_TMUX_VERSION" >"$stamp"
            say "Fetched" "catppuccin/tmux $CATPPUCCIN_TMUX_VERSION"
        else
            rm -rf "$tmp"
            warn "catppuccin download failed"
        fi
    fi

    local nav="$tmux_data/vim-tmux-navigator.tmux"
    if [ -f "$nav" ]; then
        vsay "Present" "vim-tmux-navigator"
    elif quietly curl -fsSL -o "$nav" \
        "https://raw.githubusercontent.com/christoomey/vim-tmux-navigator/$VIM_TMUX_NAVIGATOR_REF/vim-tmux-navigator.tmux"
    then
        run chmod +x "$nav"
        say "Fetched" "vim-tmux-navigator"
    else
        warn "vim-tmux-navigator download failed"
    fi
    return 0
}

# Heredoc rather than a pipe: `| while` is a subshell and would discard
# N_WARNINGS.
install_zsh_plugins() {
    phase "zsh plugins"

    local dir="$XDG_DATA_HOME/zsh/plugins"
    ensure_dir "$dir"

    local name url ref dest current
    while IFS='|' read -r name url ref; do
        [ -n "$name" ] || continue
        dest="$dir/$name"

        if [ -d "$dest/.git" ]; then
            current="$(git -C "$dest" describe --tags --exact-match 2>/dev/null || echo "")"
            if [ "$current" = "$ref" ]; then
                vsay "Current" "$name $ref"
                continue
            fi
            quietly git -C "$dest" fetch --tags origin || { warn "$name fetch failed"; continue; }
            if quietly git -C "$dest" checkout "$ref"; then
                say "Updated" "$name $ref"
            else
                warn "$name checkout $ref failed"
            fi
        elif quietly git clone --branch "$ref" --depth 1 "$url" "$dest"; then
            say "Cloned" "$name $ref"
        else
            warn "$name clone failed"
        fi
    done <<EOF
$ZSH_PLUGINS
EOF
    return 0
}

# These tools update themselves, so this only bootstraps a missing one.
install_vendor() {
    phase "Vendor"
    export PATH="$HOME/.local/bin:$PATH"

    local name cmd url
    while IFS='|' read -r name cmd url; do
        [ -n "$name" ] || continue
        if have "$cmd"; then
            vsay "Present" "$name"
        elif [ "$DRY_RUN" -eq 1 ]; then
            note "Would run" "curl -fsSL $url | bash"
        elif quietly sh -c "curl -fsSL '$url' | bash"; then
            say "Installed" "$name"
        else
            warn "$name install failed"
        fi
    done <<EOF
$VENDOR
EOF
    return 0
}

install_gh_extensions() {
    phase "gh"
    have gh || { warn "gh not found, skipping"; return 0; }

    local installed ext
    installed="$(gh extension list 2>/dev/null || true)"

    for ext in $GH_EXTENSIONS; do
        case "$installed" in
            *"$ext"*) vsay "Present" "$ext"; continue ;;
        esac
        if quietly gh extension install "$ext"; then
            say "Installed" "$ext"
        else
            warn "$ext install failed"
        fi
    done
    return 0
}

# =============================================================================
# Claude
# =============================================================================

# Merged rather than symlinked: Claude Code writes approved permissions into
# this file, and a symlink would make every approval a repo diff. Baseline
# scalars win; permissions.allow/deny are unioned with what is already there.
merge_claude_settings() {
    phase "Claude"
    have jq || { warn "jq not found, skipping"; return 0; }

    local file="$HOME/.claude/settings.json"
    local baseline="$REPO_DIR/home/.claude/settings.baseline.json"
    [ -f "$baseline" ] || { warn "baseline missing, skipping"; return 0; }

    if [ "$DRY_RUN" -eq 1 ]; then
        note "Would merge" "~/.claude/settings.json"
        return 0
    fi

    mkdir -p "$(dirname "$file")"

    local current='{}'
    [ -f "$file" ] && current="$(cat "$file")"

    local tmp
    tmp="$(mktemp "${file}.XXXXXX")"
    jq -n --argjson current "$current" --slurpfile baselineArr "$baseline" '
        ($baselineArr[0]) as $baseline
        | $current * $baseline
        | .permissions.allow = (($current.permissions.allow // []) + ($baseline.permissions.allow // []) | unique)
        | .permissions.deny  = (($current.permissions.deny  // []) + ($baseline.permissions.deny  // []) | unique)
    ' >"$tmp" || { rm -f "$tmp"; warn "merge failed, left settings.json untouched"; return 0; }

    if cmp -s "$tmp" "$file"; then
        rm -f "$tmp"
        vsay "Unchanged" "~/.claude/settings.json"
    else
        mv "$tmp" "$file"
        say "Merged" "~/.claude/settings.json"
    fi
    return 0
}

# ~/.claude/skills and ~/.opencode/skills also hold local/work-only skills, so
# unexpected entries are left alone rather than clobbered.
link_skills() {
    phase "Skills"

    local store="$HOME/.agents/skills"
    [ -d "$store" ] || { warn "$(tilde "$store") missing, skipping"; return 0; }

    local target skill client dst n
    for client in .claude .opencode; do
        ensure_dir "$HOME/$client/skills"
        n=0

        for target in "$store"/*; do
            [ -d "$target" ] || continue
            skill="$(basename "$target")"
            dst="$HOME/$client/skills/$skill"

            if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$target" ]; then
                continue
            fi
            if [ -e "$dst" ] || [ -L "$dst" ]; then
                warn "~/$client/skills/$skill exists and is not ours"
                continue
            fi
            run ln -s "$target" "$dst"
            n=$((n + 1))
        done

        if [ "$n" -gt 0 ]; then
            say "Linked" "$(plural "$n" skill) into ~/$client/skills"
        else
            vsay "Current" "~/$client/skills"
        fi
    done
    return 0
}

# Removes backups whose content the repo already has. Driven by the link map
# rather than a filesystem scan, so it can only ever touch paths this script
# created, and needs no find(1) time predicates (BSD find rejects GNU-style
# relative ones anyway).
prune_backups() {
    phase "Backups"
    build_link_map

    local record src rel bak n_same=0 n_diff=0
    local kept=""
    for record in "${LINKS[@]}"; do
        src="$REPO_DIR/home/${record%%|*}"
        rel="${record#*|}"
        for bak in "$HOME/$rel".backup "$HOME/$rel".backup.*; do
            [ -e "$bak" ] || continue
            if same_content "$src" "$bak"; then
                run rm -rf "$bak"
                n_same=$((n_same + 1))
                vsay "Removed" "$(tilde "$bak")"
            else
                n_diff=$((n_diff + 1))
                kept="$kept
$(tilde "$bak")"
            fi
        done
    done

    if [ "$n_same" -gt 0 ]; then
        say "Removed" "$(plural "$n_same" "redundant backup")"
    else
        note "Removed" "nothing; no redundant backups"
    fi
    if [ "$n_diff" -gt 0 ]; then
        say "Kept" "$(plural "$n_diff" backup) differing from the repo"
        printf '%s\n' "$kept" | while IFS= read -r bak; do
            [ -n "$bak" ] && cont "$C_DIM$bak$C_RESET"
        done
    fi
    return 0
}

update_repo() {
    phase "Update"
    [ -d "$REPO_DIR/.git" ] || { warn "$(tilde "$REPO_DIR") is not a git repo"; return 0; }

    if quietly git -C "$REPO_DIR" pull --ff-only; then
        say "Updated" "$(tilde "$REPO_DIR")"
    else
        warn "pull failed"
    fi
    return 0
}

init_rtk() {
    phase "rtk"
    export PATH="$HOME/.local/bin:$PATH"
    have rtk || { warn "rtk not found, skipping"; return 0; }

    if quietly rtk init -g; then
        say "Initialised" "rtk hooks"
    else
        warn "rtk init failed"
    fi
    return 0
}

# =============================================================================
# CLI
# =============================================================================

usage() {
    cat <<'EOF'
Usage: install.sh [options]

    --desktop             install GUI applications (default on macOS)
    --headless            skip GUI applications
    --on-conflict=MODE    prompt (default) | backup | skip | overwrite
                          backup writes ~/<file>.backup beside the original
    --only=PHASE          run one phase: packages mise links externals
                          zsh-plugins vendor gh claude skills rtk
                          or, never run by default:
                            update         git pull in the repo
                            prune-backups  delete *.backup files whose content
                                           the repo already has
    --dry-run             print what would run without running it
    -v, --verbose         show unchanged items and subprocess output
    -h, --help            print this message

EOF
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --desktop) ROLE="desktop" ;;
            --headless) ROLE="headless" ;;
            --on-conflict=*) CONFLICT_MODE="${1#*=}" ;;
            --only=*) ONLY="${1#*=}" ;;
            --dry-run) DRY_RUN=1 ;;
            -v|--verbose) VERBOSE=1 ;;
            -h|--help) usage; exit 0 ;;
            *) usage >&2; die "unknown option: $1" ;;
        esac
        shift
    done

    case "$CONFLICT_MODE" in
        prompt|backup|skip|overwrite) ;;
        *) die "--on-conflict must be prompt, backup, skip or overwrite" ;;
    esac
}

PHASES="packages mise links externals zsh-plugins vendor gh claude skills rtk"

# Opt-in only: an automatic pull would clobber uncommitted local work.
OPTIN_PHASES="update prune-backups"

run_phase() {
    local name="$1"; shift
    if [ -n "$ONLY" ]; then
        [ "$ONLY" = "$name" ] || return 0
    else
        case " $OPTIN_PHASES " in *" $name "*) return 0 ;; esac
    fi
    "$@"
}

finish() {
    local elapsed=$((SECONDS - START_TIME)) parts
    parts="$N_LINKED linked - $N_UNCHANGED unchanged - $N_BACKED_UP backed up"
    [ "$N_WARNINGS" -gt 0 ] && parts="$parts - $(plural "$N_WARNINGS" warning)"

    printf '\n'
    say "Finished" "$parts - ${elapsed}s"
    cont "restart your shell, or: exec \$SHELL -l"
    return 0
}

main() {
    parse_args "$@"

    if [ -n "$ONLY" ]; then
        case " $PHASES $OPTIN_PHASES " in
            *" $ONLY "*) ;;
            *) die "--only must be one of: $PHASES $OPTIN_PHASES" ;;
        esac
    fi

    detect_platform
    detect_role
    bootstrap_repo "$@"

    banner "$OS/$(uname -m) - $ROLE - $(tilde "$REPO_DIR")$([ "$DRY_RUN" -eq 1 ] && echo ' - dry run')"

        # mise-managed tools (gh, fd) live in the shim dir, which later phases and
    # --only=gh both need on PATH.
    export PATH="$HOME/.local/bin:$XDG_DATA_HOME/mise/shims:$PATH"

    run_phase update        update_repo
    run_phase prune-backups prune_backups
    run_phase packages    install_packages
    run_phase mise        install_mise
    run_phase links       link_dotfiles
    run_phase externals   fetch_externals
    run_phase zsh-plugins install_zsh_plugins
    run_phase vendor      install_vendor
    run_phase gh          install_gh_extensions
    run_phase claude      merge_claude_settings
    run_phase skills      link_skills
    run_phase rtk         init_rtk

    finish
}

main "$@"
