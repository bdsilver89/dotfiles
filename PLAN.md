# Dotfiles Rebuild — Design Spec

**Date:** 2026-08-13
**Status:** Approved; verified against a real Ubuntu 24.04 WSL box
**Engine:** chezmoi, fully managed (no symlink exceptions)

§7 lists every file in the repo exactly once, in build order, as a complete
copy-pasteable block. Files carried over unchanged from the old repo are listed
in §7.0 with their source path. There are no fragments and no gaps.

---

## 1. Problem

The current repo (155 tracked files, ~9.5k LOC) has four confirmed problems:

1. **Cross-platform branching.** `bootstrap.sh` (20KB) and `bootstrap.ps1` (18KB) branch internally on platform; logic for four OSes is interleaved.
2. **Tool sprawl.** Four Neovim configs, three terminal emulators, two multiplexers, two GUI editors.
3. **Unreliable new-machine setup.** Bootstrap is not dependably idempotent.
4. **Machine drift.** No mechanism to detect or reconcile divergence.

## 2. Goals and non-goals

**Goals** — one engine for all four platforms including native Windows; variation expressed declaratively rather than as shell branching; drift detectable by command; one-line fresh bootstrap; tool inventory readable on one screen; secrets structurally unable to reach the repo.

**Non-goals** — declarative package *removal* (the alternative is Nix, which cannot cover Windows); pinned system package versions (runtimes are pinned via mise, system packages float); managing GUI application state beyond config files.

## 3. Decisions

| Area | Decision | Rationale |
|---|---|---|
| Engine | chezmoi, fully managed | Only serious option treating native Windows as real; addresses all four pains |
| Source path | `~/dotfiles` | Existing habit; one path, no remote reconfiguration |
| Symlink exceptions | None | `chezmoi edit --watch` covers iterative editing; reversible per-directory later |
| Editor | Hand-rolled nvim only | Delete astronvim, lazyvim, nvim-lazyvim |
| Terminal | WezTerm everywhere | Only cross-platform option; Lua config absorbs per-OS differences; `wsl_domains`/`ssh_domains` replace Windows Terminal profiles |
| Multiplexer | tmux only | Ubiquitous on remote boxes |
| GUI editors | vscode + zed, desktop role only | Solves the remote-SSH subset problem via role exclusion |
| Shell | zsh primary, POSIX shared layer, thin bash fallback | Consistency beats per-OS defaults; bash keeps starship/fzf/zoxide/mise |
| Packages | Native pkg mgr + mise | Nix disqualified by Windows |
| Paths | Force `XDG_CONFIG_HOME` everywhere incl. Windows | Eliminates AppData duplication |
| workmux | Unix only, both roles | No Windows build; useful on headless boxes so not desktop-gated |
| opencode | All platforms, both roles | XDG-native everywhere; credentials live outside its config file |
| Migration | Branch + git worktree | Preserves history and path; both trees checked out at once |
| First target | WSL (this box) | Validates Unix and Windows halves on one machine |

**Rejected:** Stow + separate PowerShell installer (permanently forks Windows, no per-machine values or role exclusion). Nix/home-manager (no Windows). Rebuilt hand-rolled script (maintaining the engine is what produced the current state).

## 4. Target model

**Platform** — derived, never asked:

| Value | Source |
|---|---|
| `darwin` / `windows` / `linux` | `.chezmoi.os` |
| WSL | `.chezmoi.os == "linux"` AND `.chezmoi.kernel.osrelease` contains `microsoft` |
| distro | `.chezmoi.osRelease.id` |

**Role** — asked once at init, persisted in the machine-local config:

| Role | Gets |
|---|---|
| `desktop` | Everything |
| `headless` | Shell, nvim, tmux, git, bin scripts. No wezterm, vscode, zed |

| Machine | Platform | Role |
|---|---|---|
| Windows desktop | `windows` | `desktop` |
| WSL on that box | linux/WSL | `desktop` |
| macOS desktop | `darwin` | `desktop` |
| Linux desktop | `linux` | `desktop` |
| Work Linux server (LDAP) | `linux` | `headless` |
| Remote WSL2 | linux/WSL | `headless` |

## 5. Path unification

`XDG_CONFIG_HOME` is `$HOME/.config` on **every** platform, Windows included, so `~/.config/nvim` is the real path everywhere.

**Confirmed to honor XDG on Windows:** nvim, wezterm, git, bat, opencode.
**Verify in step 3:** lazygit (defaults to `%APPDATA%\lazygit`). starship and mise are pinned by env var in `10-env.sh`, so they are immune regardless.

workmux is Unix-only, so the question does not arise. The only irreducible exception is the PowerShell profile, pinned to `Documents\PowerShell\`, where Documents may be redirected into OneDrive.

## 6. Repository layout

```
~/dotfiles/                              # branch `chezmoi-rewrite`, worktree ~/dotfiles-cm
├── .chezmoiroot
├── .gitignore
├── .pre-commit-config.yaml
├── README.md
└── home/
    ├── .chezmoi.toml.tmpl
    ├── .chezmoiignore
    ├── .chezmoiexternal.toml
    ├── .chezmoidata/packages.yaml
    │
    ├── dot_zshenv
    ├── dot_profile
    ├── dot_bashrc
    ├── dot_zshrc
    ├── dot_gitconfig.tmpl
    ├── dot_vimrc
    ├── dot_ideavimrc
    ├── dot_vsvimrc
    │
    ├── dot_config/
    │   ├── sh/  00-path.sh  10-env.sh  20-aliases.sh  30-tools.sh  99-local.sh
    │   ├── zsh/ 00-completion.zsh  10-history.zsh  20-keybinds.zsh  99-plugins.zsh
    │   ├── nvim/  tmux/  wezterm/  bat/  lazygit/  starship.toml
    │   ├── workmux/config.yaml          # unix only, optional
    │   ├── opencode/opencode.json.tmpl
    │   └── zed/  Code/User/             # desktop only
    │
    ├── dot_local/bin/
    │   ├── executable_tmux-sessionizer
    │   └── executable_tmux-windowizer
    │
    ├── dot_claude/                      # allowlist; never `chezmoi add ~/.claude`
    │   ├── settings.json
    │   ├── agents/  skills/             # NOT exact_ — see §7.34
    │   ├── executable_statusline-command.sh
    │   └── statusline-command.ps1
    ├── private_dot_ssh/config.tmpl
    ├── Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
    │
    ├── run_onchange_before_10-packages-darwin.sh.tmpl
    ├── run_onchange_before_10-packages-debian.sh.tmpl
    ├── run_onchange_before_10-packages-windows.ps1.tmpl
    ├── run_onchange_before_11-extra-tools.sh.tmpl
    ├── run_onchange_after_20-mise-runtimes.sh.tmpl
    ├── run_onchange_after_21-vscode-extensions.sh.tmpl
    └── run_onchange_after_22-completions.sh.tmpl
```

**Why numeric prefixes.** The loaders source `sh/*.sh` and `zsh/*.zsh` in glob order, which is alphabetical. With bare names, `aliases.sh` would run before `path.sh`, so every `command -v eza` guard would fail on a fresh machine where eza lives in `~/.local/bin`; and a `local.sh` sourced from inside `env.sh` could not override PATH or tool init. Numeric prefixes make the intended order explicit and enforced.

---

# 7. Files

## 7.0 Index

Build in this order. Every file in §6 appears exactly once below.

| § | File | Kind |
|---|---|---|
| 7.1 | `.chezmoiroot` | new |
| 7.2 | `.gitignore` | new |
| 7.3 | `README.md` | new |
| 7.4 | `.pre-commit-config.yaml` | new |
| 7.5 | `home/.chezmoi.toml.tmpl` | new |
| 7.6 | `home/.chezmoiignore` | new |
| 7.7 | `home/.chezmoiexternal.toml` | new |
| 7.8 | `home/.chezmoidata/packages.yaml` | new |
| 7.9 | `home/dot_zshenv` | new |
| 7.10 | `home/dot_profile` | new |
| 7.11 | `home/dot_bashrc` | new |
| 7.12 | `home/dot_zshrc` | new |
| 7.13 | `home/dot_config/sh/00-path.sh` | new |
| 7.14 | `home/dot_config/sh/10-env.sh` | new |
| 7.15 | `home/dot_config/sh/20-aliases.sh` | ported |
| 7.16 | `home/dot_config/sh/30-tools.sh` | ported |
| 7.17 | `home/dot_config/sh/99-local.sh` | new |
| 7.18 | `home/dot_config/zsh/00-completion.zsh` | new |
| 7.19 | `home/dot_config/zsh/10-history.zsh` | ported |
| 7.20 | `home/dot_config/zsh/20-keybinds.zsh` | ported |
| 7.21 | `home/dot_config/zsh/99-plugins.zsh` | new |
| 7.22 | `home/dot_gitconfig.tmpl` | new |
| 7.23 | `home/private_dot_ssh/config.tmpl` | new |
| 7.24 | `home/dot_config/opencode/opencode.json.tmpl` | new |
| 7.25 | `home/dot_config/workmux/config.yaml` | deferred |
| 7.26 | `home/Documents/PowerShell/…profile.ps1.tmpl` | new |
| 7.27 | `home/run_onchange_before_10-packages-darwin.sh.tmpl` | new |
| 7.28 | `home/run_onchange_before_10-packages-debian.sh.tmpl` | new |
| 7.29 | `home/run_onchange_before_10-packages-windows.ps1.tmpl` | new |
| 7.30 | `home/run_onchange_before_11-extra-tools.sh.tmpl` | new |
| 7.31 | `home/run_onchange_after_20-mise-runtimes.sh.tmpl` | new |
| 7.32 | `home/run_onchange_after_21-vscode-extensions.sh.tmpl` | new |
| 7.33 | `home/run_onchange_after_22-completions.sh.tmpl` | new |
| 7.34 | `home/dot_claude/settings.json` | ported |

### Copied unchanged — no implementation needed

`git mv` these from the old tree; contents are not reproduced here because they
do not change.

| Destination | Source in old repo |
|---|---|
| `home/dot_config/nvim/` | `config/nvim/` |
| `home/dot_config/tmux/tmux.conf` | `config/tmux/tmux.conf` |
| `home/dot_config/tmux/themes/` | `config/tmux/themes/` |
| `home/dot_config/wezterm/wezterm.lua` | `config/wezterm/wezterm.lua` |
| `home/dot_config/bat/` | `config/bat/` |
| `home/dot_config/lazygit/config.yml` | `config/lazygit/config.yml` |
| `home/dot_config/starship.toml` | `config/starship.toml` |
| `home/dot_config/zed/` | `config/zed/` |
| `home/dot_config/Code/User/` | `config/vscode/` (settings.json, keybindings.json) |
| `home/dot_local/bin/executable_tmux-sessionizer` | `bin/tmux-sessionizer` |
| `home/dot_local/bin/executable_tmux-windowizer` | `bin/tmux-windowizer` |
| `home/dot_claude/skills/` | `claude/skills/` |
| `home/dot_claude/agents/` | *(untracked — currently only in `~/.claude/agents/`)* |
| `home/dot_claude/executable_statusline-command.sh` | `claude/statusline-command.sh` |
| `home/dot_claude/statusline-command.ps1` | `claude/statusline-command.ps1` |
| `home/dot_vimrc` | `vim/vimrc.symlink` |
| `home/dot_ideavimrc` | `vim/ideavimrc.symlink` |
| `home/dot_vsvimrc` | `vim/vsvim.symlink` |

`config/vscode/extensions.txt` is not copied — its contents move into
`packages.yaml` (§7.8) and are consumed by §7.32.

---

## 7.1 `.chezmoiroot`

```
home
```

## 7.2 `.gitignore`

```gitignore
# NOTE: .chezmoiroot, .chezmoidata/, .chezmoiignore, .chezmoiexternal.toml and
# .chezmoi.toml.tmpl MUST be committed. They are the source-of-truth control
# files. Without .chezmoiroot a fresh clone treats the repo root as the source
# dir; without .chezmoidata/ every install script renders with no packages.

# Backups and editor droppings
*.bak
*.swp

# OS clutter
.DS_Store
Thumbs.db

# Fallback protection — real secrets live outside the repo entirely
*.key
*.pem
*.token
```

## 7.3 `README.md`

```markdown
# dotfiles

chezmoi-managed dotfiles for Linux, WSL, macOS, and Windows.

## New machine

    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:brian/dotfiles.git

You will be asked for the machine's role (`desktop` or `headless`), whether it
is a work machine, and a git email. Answers are stored in
`~/.config/chezmoi/chezmoi.toml`, which is never committed.

## Daily use

| Task | Command |
|---|---|
| Edit a config | `chezmoi edit --watch ~/.config/nvim/init.lua` |
| Capture an out-of-band edit | `chezmoi add ~/.tmux.conf` |
| See drift | `chezmoi status` / `chezmoi diff` |
| Publish | `chezmoi cd && git commit -am "…" && git push` |
| Pull elsewhere | `chezmoi update` |

## Machine-local overrides

Neither file is tracked. Both are optional.

- `~/.config/sh/local.sh` — env vars, proxies, API keys
- `~/.gitconfig.local` — work email, signing keys, credential helpers
- `~/.ssh/conf.d/*.conf` — internal hosts

## Layout

- `home/` — the chezmoi source tree (see `.chezmoiroot`)
- `home/.chezmoidata/packages.yaml` — the entire tool inventory
- `home/.chezmoiignore` — the role/platform exclusion matrix
```

## 7.4 `.pre-commit-config.yaml`

Backstop only. The structural defense is that secrets live in untracked files.

```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

## 7.5 `home/.chezmoi.toml.tmpl`

Runs once at `chezmoi init`; writes `~/.config/chezmoi/chezmoi.toml`, which is never tracked.

```
{{- $role  := promptStringOnce . "role"  "Machine role (desktop/headless)" "desktop" -}}
{{- $work  := promptBoolOnce   . "work"  "Is this a work machine?" false -}}
{{- $email := promptStringOnce . "email" "Git email" "github@briansilver.net" -}}

[data]
    role  = {{ $role | quote }}
    work  = {{ $work }}
    email = {{ $email | quote }}

encryption = "none"

[edit]
    command = "nvim"
{{ if eq .chezmoi.os "windows" }}
[interpreters.ps1]
    command = "pwsh"
    args = ["-NoLogo", "-NoProfile"]
{{ end }}
```

Two traps: the email **must** be `| quote`d or the generated TOML is invalid and chezmoi cannot read its own config; and do not compute `$desktop`/`$wsl` here — `.role` does not exist in this template's context during init, so `eq .role "desktop"` errors on incompatible types. Derive those in `.chezmoiignore`, where the data does exist.

`work` has exactly two consumers: §7.24, which selects the Bedrock provider for
opencode, and one flat exclusion in §7.6, which hands `~/.claude/settings.json` over
to the machine entirely. Everything else about a work machine's Claude Code setup is
untracked by design — see §7.34.

## 7.6 `home/.chezmoiignore`

The load-bearing file — keep it a flat table. Patterns are target-relative; listed paths are never written. `README.md`, `docs/`, and `.pre-commit-config.yaml` need no entries: `.chezmoiroot` puts them outside the source tree.

```
{{- $desktop := eq .role "desktop" -}}

{{ if not $desktop }}
# headless: GUI configs never materialize
.config/wezterm
.config/zed
.config/Code
.vsvimrc
.ideavimrc
{{ end }}

{{ if ne .chezmoi.os "windows" }}
Documents/
{{ end }}

{{ if .work }}
# Work maintains its own Claude Code settings in full — see §7.34.
# Skills, agents, and the statusline scripts are still managed.
.claude/settings.json
{{ end }}

{{ if eq .chezmoi.os "windows" }}
# tmux is Unix-only; workmux depends on tmux and ships no Windows build.
.config/tmux
.config/workmux
.local/bin/tmux-sessionizer
.local/bin/tmux-windowizer
.bashrc
.profile
.zshenv
.zshrc
.config/sh
.config/zsh
{{ end }}
```

The `eq` in `{{ if eq .chezmoi.os "windows" }}` is mandatory. Writing `{{ if .chezmoi.os "windows" }}` is a template error — "can't give argument to non-function" — and fails every `chezmoi apply`.

## 7.7 `home/.chezmoiexternal.toml`

Replaces tmux-plugin submodules.

```toml
[".config/tmux/plugins/tpm"]
    type = "git-repo"
    url = "https://github.com/tmux-plugins/tpm.git"
    refreshPeriod = "168h"

[".local/share/zsh/plugins/zsh-autosuggestions"]
    type = "git-repo"
    url = "https://github.com/zsh-users/zsh-autosuggestions.git"
    refreshPeriod = "168h"

[".local/share/zsh/plugins/zsh-syntax-highlighting"]
    type = "git-repo"
    url = "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    refreshPeriod = "168h"
```

## 7.8 `home/.chezmoidata/packages.yaml`

The tool inventory on one screen. Install scripts render their lists from this, so `run_onchange_` re-triggers automatically on any edit.

```yaml
packages:
  # Present and current in every system package manager.
  core:
    - git
    - tmux
    - fzf
    - ripgrep
    - fd
    - bat
    - eza
    - zoxide
    - jq
    - zsh
    - gh

  # In Homebrew, but apt/dnf either lack these or ship versions too old.
  # Verified on Ubuntu 24.04: starship and lazygit absent; neovim is 0.9.5,
  # while the nvim config uses the lsp/ runtime directory, which needs 0.11+.
  # Installed via mise on Linux, via brew on macOS.
  unpackaged:
    - neovim
    - starship
    - lazygit

  # Own installers, all Unix platforms.
  extra:
    - mise
    - workmux
    - opencode
    - claude-code

  # apt package names that differ from the canonical name.
  # NOTE: on Ubuntu the bat *package* is `bat`; only the *binary* is batcat.
  # Do not map bat here — `apt install batcat` fails.
  apt_names:
    fd: fd-find

  desktop:
    darwin:
      casks: [wezterm, visual-studio-code, zed]
    linux:
      apt: [wezterm]
    windows:
      winget: [wez.wezterm, Microsoft.VisualStudioCode, Zed.Zed]
      scoop:  [opencode]

  vscode_extensions:
    - vscodevim.vim
    - ms-vscode-remote.remote-ssh

  mise_runtimes:
    - node@lts
    - python@3.14
    - rust@stable
```

## Shell architecture (context for 7.9–7.21)

```
                     ┌──────────────────────────┐
   .zshrc ──────────►│  ~/.config/sh/*.sh       │◄────────── .bashrc
       │             │  POSIX ONLY, in order:   │            (+ exec-zsh handoff)
       │             │  00-path  10-env         │
       │             │  20-aliases  30-tools    │
       ▼             │  99-local                │
  ~/.config/zsh/*.zsh└──────────────────────────┘
  00-completion 10-history 20-keybinds 99-plugins
```

**The rule that keeps this from rotting: nothing bash-specific is ever written**, beyond the small block already in `.bashrc`. Bash is a degraded mode, not a peer.

## 7.9 `home/dot_zshenv`

```sh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
```

## 7.10 `home/dot_profile`

Non-interactive login sessions — `scp`, `rsync`, VS Code Remote server startup. PATH and env, nothing interactive.

```sh
. "$HOME/.config/sh/00-path.sh"
. "$HOME/.config/sh/10-env.sh"
```

## 7.11 `home/dot_bashrc`

```sh
# Interactive only. Without this guard, scp/rsync/git-over-ssh and VS Code
# Remote's server startup all break.
case $- in *i*) ;; *) return ;; esac

# Hand off to zsh where chsh is blocked. LDAP/SSSD accounts have no
# /etc/passwd entry, so chsh can never work on those boxes.
# Escape hatch: ssh host -t bash --noprofile
if [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
    exec zsh -l
fi

# Unquoted so the glob expands. A quoted glob does not expand — it would loop
# once over the literal pattern and source nothing at all.
for f in "$HOME"/.config/sh/*.sh; do
    [ -r "$f" ] && . "$f"
done
unset f

# The only bash-specific lines permitted in this repo.
shopt -s histappend checkwinsize
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups
set -o vi
[ -f "$HOME/.fzf.bash" ] && . "$HOME/.fzf.bash"
```

## 7.12 `home/dot_zshrc`

```sh
# (N) is zsh's null_glob qualifier: yields an empty list instead of erroring
# when nothing matches.
for f in "$HOME"/.config/sh/*.sh(N); do
    [ -r "$f" ] && . "$f"
done
for f in "$HOME"/.config/zsh/*.zsh(N); do
    [ -r "$f" ] && . "$f"
done
unset f
```

## 7.13 `home/dot_config/sh/00-path.sh`

```sh
_prepend_path() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) [ -d "$1" ] && PATH="$1:$PATH" ;;
    esac
}

_prepend_path "$HOME/.local/bin"
_prepend_path "$HOME/bin"
[ -d /opt/homebrew/bin ] && _prepend_path /opt/homebrew/bin
[ -d /home/linuxbrew/.linuxbrew/bin ] && _prepend_path /home/linuxbrew/.linuxbrew/bin

export PATH
unset -f _prepend_path
```

## 7.14 `home/dot_config/sh/10-env.sh`

```sh
# .zshenv sets these for zsh, but bash never reads it, so they must be set here
# too — otherwise STARSHIP_CONFIG resolves to /starship.toml in every bash
# session. Idempotent, so double-setting is harmless.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-FRX'

# Pinned explicitly rather than relying on XDG discovery, which makes these two
# immune to the Windows XDG question entirely.
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"

export EZA_COLORS="uu=36:uR=31:un=35:gu=37:da=2;34:ur=34:uw=95:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:xx=95"
```

## 7.15 `home/dot_config/sh/20-aliases.sh`

Ported from `profile.d/20_navigation/01_aliases.sh`. Runs after `00-path.sh`, so the `command -v` guards see `~/.local/bin`.

```sh
alias c="clear"

alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."

alias df="df -h"
alias pg="ps aux | grep -v grep | grep -i -e VSZ -e"

if command -v eza >/dev/null 2>&1; then
    alias l="eza --color=always --icons=always --git"
    alias ll="eza --color=always --icons=always --git -lagSX"
    alias lt="eza --color=always --tree --level=2 --icons=always --long --git"
else
    alias l="ls --color=auto"
    alias ll="ls -lah --color=auto"
    command -v tree >/dev/null 2>&1 && alias lt="tree"
fi

# Debian ships these under different binary names. The apt script also symlinks
# them into ~/.local/bin; these cover boxes where it has not run.
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat="batcat"
command -v fdfind >/dev/null 2>&1 && ! command -v fd  >/dev/null 2>&1 && alias fd="fdfind"

command -v fzf >/dev/null 2>&1 && alias f='$EDITOR "$(fzf)"'

alias g="git"
command -v lazygit >/dev/null 2>&1 && alias gg="lazygit"

# Used by gmom/gmum. Previously inherited from oh-my-zsh, which this config
# does not use.
git_main_branch() {
    git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null \
        | sed 's|^origin/||' \
        || echo main
}

alias ga='git add'
alias gbl='git blame -w'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gclean='git clean --interactive -d'
alias gcl='git clone --recurse-submodules'
alias gc='git commit --verbose'
alias gcmsg='git commit --message'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gf='git fetch'
alias gfo='git fetch origin'
alias glgg='git log --graph'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glg='git log --stat'
alias glgp='git log --stat --patch'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias gfg='git ls-files | grep'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms="git merge --squash"
alias gmff="git merge --ff-only"
alias gmom='git merge origin/$(git_main_branch)'
alias gmum='git merge upstream/$(git_main_branch)'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias gl='git pull'
alias gp='git push'
alias gpd='git push --dry-run'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grh='git reset'
alias grs='git restore'
alias gst='git status'
alias gsta='git stash push'
alias gstp='git stash pop'
alias gwta="git worktree add"
alias gwtls="git worktree list"
alias gwtmv="git worktree move"
alias gwtrm="git worktree remove"
```

## 7.16 `home/dot_config/sh/30-tools.sh`

Shell-agnostic tool init; each tool ships both bash and zsh hooks. Runs after `00-path.sh` so the binaries are findable. Merges the old `20_navigation/02_fzf.sh`, `03_zoxide.sh`, and `30_shell/03_prompt.sh`.

```sh
_shell_name() {
    [ -n "$ZSH_VERSION" ] && { echo zsh; return; }
    echo bash
}
_sh="$(_shell_name)"

if command -v fzf >/dev/null 2>&1; then
    if command -v bat >/dev/null 2>&1; then
        FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"
    else
        FZF_DEFAULT_OPTS="--preview 'cat {}'"
    fi
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default"
    eval "$(fzf --"$_sh")"
fi

command -v mise     >/dev/null 2>&1 && eval "$(mise activate "$_sh")"
command -v zoxide   >/dev/null 2>&1 && eval "$(zoxide init "$_sh")"
command -v starship >/dev/null 2>&1 && eval "$(starship init "$_sh")"

unset _sh
unset -f _shell_name
```

## 7.17 `home/dot_config/sh/99-local.sh`

```sh
# Untracked, machine-local: work proxies, internal registries, tokens, API keys.
#
# Its own file rather than the tail of 10-env.sh because the loader sources in
# glob order. Inside 10-env.sh it would run before 00-path.sh and 30-tools.sh
# and so could not override PATH or tool init. The 99- prefix guarantees last.
[ -f "$XDG_CONFIG_HOME/sh/local.sh" ] && . "$XDG_CONFIG_HOME/sh/local.sh"
```

## 7.18 `home/dot_config/zsh/00-completion.zsh`

Must run before `99-plugins.zsh`. Without this file there is no `compinit` anywhere and zsh has no completion system at all.

```sh
# Generated completions (workmux writes here) must be on fpath before compinit.
fpath=("${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions" $fpath)

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zcompcache"
```

## 7.19 `home/dot_config/zsh/10-history.zsh`

Ported from `profile.d/30_shell/02_history.sh`, with the file moved under XDG state.

```sh
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
mkdir -p "${HISTFILE:h}"

setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
```

Existing history is not migrated automatically. Carry it over once:

```sh
mkdir -p ~/.local/state/zsh && cat ~/.zsh_history >> ~/.local/state/zsh/history
```

## 7.20 `home/dot_config/zsh/20-keybinds.zsh`

Ported from `profile.d/30_shell/01_bindings.sh`. `^r` is left to fzf, which binds it in `30-tools.sh`.

```sh
bindkey -v
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
```

## 7.21 `home/dot_config/zsh/99-plugins.zsh`

Sources plugins fetched by `.chezmoiexternal.toml`. Loads last because syntax highlighting must wrap every widget defined before it.

```sh
ZSH_PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

[ -r "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && . "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Must be last.
[ -r "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
    && . "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
```

## 7.22 `home/dot_gitconfig.tmpl`

```
[user]
    name  = Brian Silver
    email = {{ .email }}

[core]
    editor = nvim
{{- if eq .chezmoi.os "windows" }}
    autocrlf = input
{{- end }}

[init]
    defaultBranch = main

[include]
    # Untracked. Work signing keys, internal URLs, credential helpers.
    # Git silently ignores a missing include, so personal machines need no file.
    path = ~/.gitconfig.local
```

## 7.23 `home/private_dot_ssh/config.tmpl`

The `private_` prefix gives the file mode 0600 and the directory 0700.

```
# Machine-local hosts come first: ssh honors the EARLIEST matching directive,
# so anything included later cannot override these defaults.
# A glob that matches nothing is not an error, so no placeholder file is needed.
Include ~/.ssh/conf.d/*.conf

Host *
    AddKeysToAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    HashKnownHosts no
{{- if eq .chezmoi.os "darwin" }}
    UseKeychain yes
{{- end }}
```

Internal hostnames are themselves sensitive; they belong in `~/.ssh/conf.d/`, which is never tracked.

## 7.24 `home/dot_config/opencode/opencode.json.tmpl`

Safe to track either way: opencode never inlines credentials. On a personal machine
it resolves `{env:VAR}` and `{file:path}` references at run time; on a work machine
the `amazon-bedrock` provider takes no key at all and reads the standard AWS
credential chain, so there is nothing to inline.

```
{
  "$schema": "https://opencode.ai/config.json",
{{- if .work }}
  "provider": {
    "amazon-bedrock": {}
  }
{{- else }}
  "provider": {
    "anthropic": {
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}"
      }
    }
  }
{{- end }}
}
```

The personal key goes in the untracked `~/.config/sh/local.sh`:

```sh
export ANTHROPIC_API_KEY='…'
```

**Verify in step 4.** The provider id `amazon-bedrock` and the model-id form
(`us.anthropic.claude-…-v1:0` inference profiles, *not* the `anthropic.`-prefixed
Mantle ids) are inferred from opencode routing Bedrock through the AI SDK rather
than confirmed against its schema. If the work account is not entitled to opencode's
default model, pin one with a top-level `"model"` key.

This file is templated while Claude Code's settings (§7.34) are excluded outright on
work machines. The asymmetry is deliberate: opencode's work delta is three non-secret
lines, worth templating for reproducibility, while Claude Code's spans four surfaces
and includes internal MCP endpoints.

Add model and agent settings per upstream docs once the basics work.

## 7.25 `home/dot_config/workmux/config.yaml`

**Deferred — do not create yet.** workmux runs without a global config, and I have not verified its schema. Use it for a week, then capture the settings you actually want and add the file. The `.chezmoiignore` entry for Windows (§7.6) is already in place and is harmless while the file does not exist.

Per-repo `.workmux.yaml` files live in project repos and are never managed here.

## 7.26 `home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`

The one irreducible non-XDG path. Documents may be redirected into OneDrive — check `$PROFILE` on the machine in step 3 and adjust the source path if it differs.

```
$env:EDITOR = 'nvim'
Set-Alias -Name vim -Value nvim
Set-Alias -Name g   -Value git

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
```

## 7.27 `home/run_onchange_before_10-packages-darwin.sh.tmpl`

Four single-purpose install scripts follow. `.chezmoiignore` excludes the irrelevant ones, so the Debian script is not *skipped at runtime* on a Mac — it is never written to disk.

```
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/sh
set -eu

command -v brew >/dev/null 2>&1 || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install \
{{- range .packages.core }}
    {{ . }} \
{{- end }}
{{- range .packages.unpackaged }}
    {{ . }} \
{{- end }}
    ;
{{ if eq .role "desktop" }}
brew install --cask \
{{- range .packages.desktop.darwin.casks }}
    {{ . }} \
{{- end }}
    ;
{{ end }}
{{- end }}
```

## 7.28 `home/run_onchange_before_10-packages-debian.sh.tmpl`

```
{{- if and (eq .chezmoi.os "linux") (has .chezmoi.osRelease.id (list "ubuntu" "debian")) -}}
#!/bin/sh
set -eu

sudo apt-get update
sudo apt-get install -y \
{{- range .packages.core }}
    {{ index $.packages.apt_names . | default . }} \
{{- end }}
    ;
{{ if eq .role "desktop" }}
sudo apt-get install -y \
{{- range .packages.desktop.linux.apt }}
    {{ . }} \
{{- end }}
    ;
{{ end }}
# Debian names these binaries differently; expose the canonical names.
mkdir -p "$HOME/.local/bin"
[ -x /usr/bin/batcat ] && ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
[ -x /usr/bin/fdfind ] && ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
{{- end }}
```

`packages.unpackaged` is deliberately absent — those come from mise in §7.30. WezTerm is not in Debian's default repos; the desktop block assumes their apt source has been added. Verify in step 6, or fall back to their `.deb` release.

## 7.29 `home/run_onchange_before_10-packages-windows.ps1.tmpl`

Requires the `[interpreters.ps1]` block from §7.5.

```
{{- if eq .chezmoi.os "windows" -}}
$ErrorActionPreference = 'Stop'

[Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', "$env:USERPROFILE\.config",      'User')
[Environment]::SetEnvironmentVariable('XDG_DATA_HOME',   "$env:USERPROFILE\.local\share", 'User')
[Environment]::SetEnvironmentVariable('XDG_CACHE_HOME',  "$env:USERPROFILE\.cache",       'User')
{{ range .packages.desktop.windows.winget }}
winget install --id {{ . }} --silent --accept-package-agreements --accept-source-agreements
{{- end }}
{{ range .packages.desktop.windows.scoop }}
scoop install {{ . }}
{{- end }}
{{- end }}
```

Upstream recommends WSL over native Windows for opencode. Since WSL is a managed target in its own right, treat the scoop line as optional — if it proves fussy, drop it and use opencode from WSL.

## 7.30 `home/run_onchange_before_11-extra-tools.sh.tmpl`

Everything the system package manager cannot supply: mise itself, the three `unpackaged` tools on Linux, and the two `extra` tools everywhere.

```
{{- if ne .chezmoi.os "windows" -}}
#!/bin/sh
set -eu

# Inlined so run_onchange re-triggers when either list changes:
# extra:      {{ .packages.extra | join " " }}
# unpackaged: {{ .packages.unpackaged | join " " }}

command -v mise >/dev/null 2>&1 || curl -fsSL https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
{{ if eq .chezmoi.os "darwin" }}
command -v workmux  >/dev/null 2>&1 || brew install raine/workmux/workmux
command -v opencode >/dev/null 2>&1 || brew install anomalyco/tap/opencode
command -v claude   >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
{{ else }}
# apt has no starship or lazygit, and its neovim (0.9.5 on Ubuntu 24.04) predates
# the lsp/ runtime directory this config relies on. mise handles arch detection.
{{- range .packages.unpackaged }}
mise use -g {{ . }}@latest
{{- end }}

command -v workmux >/dev/null 2>&1 || \
    curl -fsSL https://raw.githubusercontent.com/raine/workmux/main/scripts/install.sh | bash
command -v opencode >/dev/null 2>&1 || \
    curl -fsSL https://opencode.ai/install | bash
command -v claude >/dev/null 2>&1 || \
    curl -fsSL https://claude.ai/install.sh | bash
{{ end }}
{{- end }}
```

The `command -v` guards make this re-runnable but mean it will not *upgrade* an already-installed tool; upgrades are a manual `brew upgrade` or `mise upgrade`. Acceptable at this size — revisit past four tools.

Confirm on first run that mise's registry resolves `neovim`, `starship`, and `lazygit`. If one does not, fall back to that project's own installer. Confirm the Claude Code installer URL too — on macOS `brew install --cask claude-code` is the fallback.

## 7.31 `home/run_onchange_after_20-mise-runtimes.sh.tmpl`

```
{{- if ne .chezmoi.os "windows" -}}
#!/bin/sh
set -eu

# runtimes: {{ .packages.mise_runtimes | join " " }}
command -v mise >/dev/null 2>&1 || exit 0
{{- range .packages.mise_runtimes }}
mise use -g {{ . }}
{{- end }}
{{- end }}
```

## 7.32 `home/run_onchange_after_21-vscode-extensions.sh.tmpl`

Desktop role only. Replaces `config/vscode/extensions.txt`.

```
{{- if and (eq .role "desktop") (ne .chezmoi.os "windows") -}}
#!/bin/sh
set -eu

# extensions: {{ .packages.vscode_extensions | join " " }}
command -v code >/dev/null 2>&1 || exit 0
{{- range .packages.vscode_extensions }}
code --install-extension {{ . }} --force
{{- end }}
{{- end }}
```

Windows is excluded because this is a `.sh` script. If you want extensions installed natively on Windows too, add a `.ps1` sibling in step 3; otherwise VS Code's own Settings Sync covers it.

## 7.33 `home/run_onchange_after_22-completions.sh.tmpl`

workmux generates completions rather than shipping them.

```
{{- if ne .chezmoi.os "windows" -}}
#!/bin/sh
set -eu

COMPDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
mkdir -p "$COMPDIR"
command -v workmux >/dev/null 2>&1 && workmux completions zsh > "$COMPDIR/_workmux"
{{- end }}
```

The directory is put on `fpath` before `compinit` by §7.18; without that ordering the completion is silently ignored.

## 7.34 `home/dot_claude/settings.json`

### `~/.claude` is mostly runtime state

Of the 33 entries in a live `~/.claude`, five are configuration. The rest is churn:
`history.jsonl` alone is 1.2 MB, plus `daemon.log`, `sessions/`, `projects/`,
`file-history/`, `session-env/`, `tasks/`, `shell-snapshots/`, and several caches.

**Never run `chezmoi add ~/.claude`.** The source tree is an explicit allowlist:

| Tracked | Not tracked |
|---|---|
| `settings.json` | everything else |
| `agents/` | |
| `skills/` | |
| `executable_statusline-command.sh` | |
| `statusline-command.ps1` | |

### No `exact_` prefix — this is the load-bearing rule

Work machines carry their own subagents, skills, hooks, commands, and MCP server
definitions in the same directories, and none of it is tracked here. A normal
chezmoi-managed directory leaves unknown files alone; an `exact_` directory deletes
them. So `exact_dot_claude/`, `exact_agents/`, or `exact_skills/` would silently wipe
a work machine's Claude setup on every `chezmoi apply`.

This is the one place in the repo where an `exact_` prefix would be actively
destructive. Anything added under `dot_claude/` later must keep the plain form.

### The file

Ported from the live `~/.claude/settings.json`. Two keys are dropped in the port —
`feedbackSurveyState` and `attribution` — because Claude Code rewrites them at run
time and they would show up as permanent drift in `chezmoi status`.

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)",
      "Bash(git show:*)", "Bash(git branch:*)", "Bash(git blame:*)",
      "Bash(git worktree list:*)", "Bash(git remote -v)",
      "Bash(rg:*)", "Bash(fd:*)", "Bash(eza:*)", "Bash(bat:*)", "Bash(jq:*)",
      "Bash(cargo check:*)", "Bash(cargo clippy:*)", "Bash(cargo fmt:*)",
      "Bash(cargo tree:*)", "Bash(cargo metadata:*)",
      "Bash(ruff check:*)", "Bash(ruff format:*)",
      "Bash(mypy:*)", "Bash(basedpyright:*)", "Bash(tsc --noEmit:*)",
      "Bash(clang-format:*)", "Bash(clang-tidy:*)",
      "Read(//tmp/**)"
    ],
    "deny": [
      "Read(**/.env)", "Read(**/.env.*)",
      "Read(~/.aws/**)", "Read(~/.ssh/**)",
      "Read(**/*.pem)", "Read(**/*.key)", "Read(**/credentials)"
    ],
    "ask": []
  },
  "model": "opus[1m]",
  "statusLine": {
    "type": "command",
    "command": "sh ~/.claude/statusline-command.sh",
    "padding": 1,
    "refreshInterval": 1
  },
  "enabledPlugins": {
    "superpowers@superpowers-marketplace": true,
    "ralph-loop@claude-plugins-official": true,
    "linear@claude-plugins-official": true,
    "rust-analyzer-lsp@claude-plugins-official": true
  },
  "effortLevel": "high",
  "tui": "fullscreen",
  "editorMode": "vim",
  "skipWorkflowUsageWarning": true,
  "skipAutoPermissionPrompt": true,
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

The `deny` list already blocks `Read(~/.aws/**)`, which matters more once work
machines authenticate through Bedrock — see §8.

### Work machines own this file outright

Work's Claude Code config differs across all four surfaces — settings, agents and
skills, MCP servers, and hooks and commands — and the MCP endpoints in particular
name internal infrastructure. None of it belongs in a repo that pushes to a personal
GitHub remote, so none of it is tracked.

The mechanism is the single flat exclusion in §7.6: on a work machine
`.claude/settings.json` is never written, and the machine's own copy is left alone.
Skills, agents, and the statusline scripts are still managed there, which is the
point of splitting the allowlist rather than excluding `dot_claude/` wholesale.

Bedrock selection moves into that machine-local file:

```json
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1"
  }
}
```

Region, profile, and credentials stay out of it — they come from `~/.aws/config` and
`~/.aws/sso/cache/`. `local.sh` carries the two non-secret pointers:

```sh
export AWS_PROFILE=…
export AWS_REGION=…
```

If the work account is not entitled to Claude Code's default model, pin
`ANTHROPIC_MODEL` (and `ANTHROPIC_DEFAULT_HAIKU_MODEL`) in the same `env` block, set
to the Bedrock inference-profile ids the account actually has.

### Two things to verify in step 4

**Whether `~/.claude/settings.local.json` is merged at the user level.** Claude Code
documents `.claude/settings.local.json` as a *project*-level override; a user-level
equivalent would be strictly better than the whole-file exclusion above, because work
would inherit the shared permission allowlist instead of duplicating it. Confirm on
the work box; if it works, replace the §7.6 exclusion with a tracked `settings.json`
plus an untracked `settings.local.json`. If it does not, the exclusion stands.

**That `chezmoi apply` does not delete untracked files** under `~/.claude/agents/`
and `~/.claude/skills/`. This is the `exact_` rule above, and it is worth proving on
a real work machine rather than trusting the prefix convention.

### Migration note

`~/.claude/statusline-command.sh` is currently a symlink into `~/dotfiles/claude/`,
the `.symlink` convention §9 deletes. Remove it before the first `chezmoi apply` on
each machine, or apply will write through the symlink into the old tree instead of
replacing it.

---

## 8. Secrets model

Three tiers, strictly separated.

| Tier | Location | Tracked | Contents |
|---|---|---|---|
| Public config | `~/dotfiles/home/**` | Yes | aliases, keybinds, nvim, tmux, opencode.json, Claude Code settings |
| Machine variables | `~/.config/chezmoi/chezmoi.toml` | No | `role`, `work`, `email` |
| Secrets | `~/.config/sh/local.sh`, `~/.gitconfig.local`, `~/.ssh/conf.d/*.conf` | No | tokens, API keys, internal URLs, proxies, signing keys, internal hostnames, `AWS_PROFILE`/`AWS_REGION` |
| Cloud credentials | `~/.aws/config`, `~/.aws/credentials`, `~/.aws/sso/cache/` | No | AWS profiles, SSO tokens, any Bedrock gateway endpoint |
| Work Claude config | `~/.claude/settings.json` (work only), plus work-only entries under `~/.claude/agents/`, `skills/`, and any hooks or commands | No | internal MCP endpoints, work permission rules, Bedrock env |

Keys obtained through opencode's interactive `/connect` are stored outside `~/.config/opencode`. Confirm during step 1 by running `chezmoi diff` after a `/connect` and checking nothing new appears.

No encrypted tier for now. Add `age` later if versioning an actual key becomes worthwhile.

## 9. Deletion list

```
config/astronvim/      config/lazyvim/       config/nvim-lazyvim/
config/alacritty/      config/ghostty/       config/windows-terminal/
config/yabai/          config/skhd/          bin/zellij-sessionizer
bin/wsl-reclaim        bootstrap.sh          bootstrap.ps1
install.sh             profile.d/            WindowsPowerShell/
Brewfile               config/vscode/extensions.txt
config/tmux/plugins/   (submodules → .chezmoiexternal.toml)
bash/  zsh/  git/  vim/  (relocated; the *.symlink convention is dropped)
```

Expected result: 155 tracked files → roughly 50–60.

## 10. Migration plan

Each step ends with a fully working machine. No hybrid states.

**Step 0 — scaffold.** `git worktree add ~/dotfiles-cm -b chezmoi-rewrite`. Old setup on `main` stays deployed everywhere.

**Step 1 — shared core on this WSL box.** Build §7.1–7.33, then:

```sh
chezmoi init --source=~/dotfiles-cm
chezmoi diff        # review before anything is written
chezmoi apply
```

Verify: correct PATH and prompt in a new shell; autosuggestions and syntax highlighting active; tab-completion works; `nvim --version` is 0.11+ and LSP attaches; tmux starts with plugins fetched by externals; `workmux add` creates a worktree and window; `opencode` starts and resolves its key from `local.sh`; `chezmoi status` clean after an opencode `/connect`.

**Step 2 — headless role, same box.** Set `role = "headless"` in a scratch config and run `chezmoi diff`. Confirm the wezterm/zed/Code targets are absent from the diff entirely. Validates the role split without a second machine.

**Step 3 — Windows, same physical machine.** Install chezmoi and pwsh, then `chezmoi init --apply`. **Verify the XDG bet explicitly before proceeding:** confirm nvim, wezterm, git, bat, lazygit, and opencode each read from `~/.config`. Anything that does not gets a Windows-specific target path and a note here. This is the design's largest untested assumption.

**Step 4 — headless on the LDAP work server.** Verify the `exec zsh -l` handoff fires on interactive login and does *not* fire for `ssh host true`, `scp`, or VS Code Remote. Confirm no GUI config was written.

This is also the first `work = true` machine, so it is where the Bedrock path gets proved:

- `chezmoi diff` shows no entry for `.claude/settings.json` — the §7.6 exclusion fired, and the machine's own settings survive untouched.
- **`chezmoi apply` deletes nothing** under `~/.claude/agents/` or `~/.claude/skills/`. Drop a scratch file in each, apply, confirm both are still there. This proves the `exact_` rule in §7.34.
- `claude` authenticates against Bedrock without prompting for a Max login.
- `~/.config/opencode/opencode.json` renders the `amazon-bedrock` provider, and opencode reaches a model the account is entitled to (§7.24's unverified assumption).
- `chezmoi status` is clean — no AWS profile, region, account id, or internal MCP endpoint has reached a tracked file.
- Test whether a user-level `~/.claude/settings.local.json` is merged (§7.34). If it is, adopt it and drop the §7.6 exclusion.

**Step 5 — macOS desktop.** Full profile including casks.

**Step 6 — Linux desktop, then merge.**

```sh
cd ~/dotfiles && git switch main && git merge chezmoi-rewrite
git worktree remove ~/dotfiles-cm
```

Delete the old entry points in the merge commit.

## 11. Daily operation

| Task | Command |
|---|---|
| Edit a config | `chezmoi edit --watch ~/.config/nvim/init.lua` |
| Capture an out-of-band edit | `chezmoi add ~/.tmux.conf` |
| See local drift | `chezmoi status`, `chezmoi diff` |
| Publish | `chezmoi cd && git commit -am "…" && git push` |
| Sync another machine | `chezmoi update` |
| New machine | `chezmoi init --apply git@github.com:brian/dotfiles.git` |

## 12. Risks

**`.chezmoiignore` is load-bearing.** It encodes the whole role/platform matrix. Keep it a flat table; when a rule needs real logic, split into separate per-platform files and exclude whole files instead. `work` is a third axis on top of role × platform, so it earns exactly one flat line — `.claude/settings.json` — and nothing more. Its other effect (§7.24) is a template, because there the delta is three non-secret lines rather than a whole file.

**Work Claude Code config is invisible to `chezmoi status`.** §2 lists drift detection as a goal, and this is the one deliberate hole in it: everything under `~/.claude` on a work machine except skills, agents, and the statusline scripts is unmanaged. That is the price of keeping internal MCP endpoints out of a repo with a personal remote. Revisit only if an encrypted tier (§8) is added later.

**An `exact_` prefix under `dot_claude/` would be destructive.** See §7.34 — it would delete a work machine's untracked agents, skills, hooks, and commands on every apply. Nothing else in the repo has this property, which is exactly why it is easy to add by reflex.

**The XDG-on-Windows bet.** nvim, wezterm, git, bat, and opencode are confirmed. lazygit needs verification in step 3; starship and mise are pinned by env var and so are immune. If lazygit fails, give it a Windows-specific target path — contained, not fatal.

**Over-templating.** Template only where files genuinely differ; prefer separate files plus `.chezmoiignore` over inline conditionals. More than one level of nesting means split the file.

**No package removal.** Deleting from `packages.yaml` never uninstalls. If this becomes a real problem, add a reconciliation script that diffs installed against declared — do not reach for Nix, which cannot serve the Windows half.

**Branch longevity.** Timebox steps 1–3 to about a week and merge once two machines are migrated, rather than waiting for all six.
