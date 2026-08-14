# Dotfiles Rebuild — Design Spec

**Date:** 2026-08-14
**Status:** Approved; verified against a real Ubuntu 24.04 WSL box
**Engine:** chezmoi, fully managed (no symlink exceptions)

§7 lists every file in the repo exactly once, in build order, as a complete
copy-pasteable block. Files carried over unchanged from the old repo are listed
in §7.0 with their source path. There are no fragments and no gaps.

**Revision, 2026-08-14.** §7.35–7.54 added: every tool config is now specified
rather than "copied unchanged". Reading the old configs against §4 showed most
of them encode assumptions this design removes, and three were outright broken
(see the table at the end of §7.0). The same pass introduced `theme` as a third
machine variable — §7.35 — because eleven files were about to hard-code the same
palette in eleven syntaxes.

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

**Theme** — asked once at init, but unlike role and work it is expected to
change later, so §7.35 ships a command for it. It is orthogonal to both other
axes: it changes what is *in* files, never which files exist.

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
    ├── .chezmoiexternal.toml.tmpl
    ├── .chezmoidata/
    │   ├── packages.yaml
    │   └── themes.yaml                  # the `theme` variable — §7.35
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
    ├── .chezmoitemplates/
    │   └── vscode/  settings.json  keybindings.json   # one copy, three targets
    │
    ├── dot_config/
    │   ├── sh/  00-path.sh  10-env.sh.tmpl  20-aliases.sh  30-tools.sh  99-local.sh
    │   ├── zsh/ 00-completion.zsh  10-history.zsh  20-keybinds.zsh  99-plugins.zsh
    │   ├── nvim/                        # carried over; + theme.lua.tmpl, §7.50
    │   ├── tmux/  tmux.conf  themes/theme.conf.tmpl
    │   ├── wezterm/wezterm.lua.tmpl     # desktop only
    │   ├── bat/config.tmpl
    │   ├── lazygit/config.yml.tmpl
    │   ├── git/ignore                   # global gitignore, XDG default path
    │   ├── starship.toml.tmpl
    │   ├── workmux/config.yaml          # unix only
    │   ├── opencode/opencode.json.tmpl
    │   ├── zed/  settings.json.tmpl  keymap.json  tasks.json   # desktop only
    │   └── Code/User/                   # desktop + linux only — see §7.43
    │       ├── settings.json.tmpl
    │       └── keybindings.json.tmpl
    │
    ├── Library/Application Support/Code/User/   # desktop + darwin only
    │   ├── settings.json.tmpl
    │   └── keybindings.json.tmpl
    ├── AppData/Roaming/Code/User/               # desktop + windows only
    │   ├── settings.json.tmpl
    │   └── keybindings.json.tmpl
    │
    ├── dot_local/bin/
    │   ├── executable_tmux-sessionizer
    │   ├── executable_tmux-windowizer
    │   └── executable_theme              # colour-scheme switcher — §7.35
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
    ├── run_onchange_after_22-completions.sh.tmpl
    └── run_onchange_after_23-bat-cache.sh.tmpl      # only for themes that
                                                     # need a .tmtheme — §7.41
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
| 7.7 | `home/.chezmoiexternal.toml.tmpl` | new |
| 7.8 | `home/.chezmoidata/packages.yaml` | new |
| 7.9 | `home/dot_zshenv` | new |
| 7.10 | `home/dot_profile` | new |
| 7.11 | `home/dot_bashrc` | new |
| 7.12 | `home/dot_zshrc` | new |
| 7.13 | `home/dot_config/sh/00-path.sh` | new |
| 7.14 | `home/dot_config/sh/10-env.sh.tmpl` | new |
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
| 7.35 | `home/.chezmoidata/themes.yaml` + `dot_local/bin/executable_theme` | new |
| 7.36 | `home/dot_config/wezterm/wezterm.lua.tmpl` | rewritten |
| 7.37 | `home/dot_config/tmux/tmux.conf` | rewritten |
| 7.38 | `home/dot_config/tmux/themes/theme.conf.tmpl` | rewritten |
| 7.39 | `home/dot_config/lazygit/config.yml.tmpl` | rewritten |
| 7.40 | `home/dot_config/starship.toml.tmpl` | rewritten |
| 7.41 | `home/dot_config/bat/config.tmpl` + `…23-bat-cache.sh.tmpl` | rewritten |
| 7.42 | `home/dot_config/git/ignore` | new |
| 7.43 | `home/.chezmoitemplates/vscode/settings.json` + 3 path shims | rewritten |
| 7.44 | `home/.chezmoitemplates/vscode/keybindings.json` | ported |
| 7.45 | `home/dot_config/zed/settings.json.tmpl` | rewritten |
| 7.46 | `home/dot_config/zed/keymap.json` | ported |
| 7.47 | `home/dot_config/zed/tasks.json` | rewritten |
| 7.48 | `home/dot_local/bin/executable_tmux-sessionizer` | rewritten |
| 7.49 | `home/dot_local/bin/executable_tmux-windowizer` | ported |
| 7.50 | `home/dot_config/nvim/` + `lua/theme.lua.tmpl` | carried, with edits |
| 7.51 | `home/dot_vimrc`, `dot_ideavimrc`, `dot_vsvimrc` | ported, with fixes |
| 7.52 | `home/dot_claude/executable_statusline-command.sh` | rewritten |
| 7.53 | `home/dot_claude/statusline-command.ps1` | rewritten |
| 7.54 | `home/dot_claude/skills/` and `agents/` | inventory |

### Genuinely copied unchanged

Only two things move byte-for-byte. Everything else in the old `config/` tree is
either rewritten below or deleted (§9).

| Destination | Source in old repo |
|---|---|
| `home/dot_config/nvim/lua/`, `lsp/`, `init.lua`, `stylua.toml` | `config/nvim/` — minus the two files named in §7.50 |
| `home/dot_claude/skills/*/` | `claude/skills/` — 13 directories, listed in §7.54 |

`config/vscode/extensions.txt` is not copied — its contents move into
`packages.yaml` (§7.8) and are consumed by §7.32.

### Why so much is "rewritten"

The first draft of this plan assumed the tool configs could be carried over
untouched. Reading them against the target model in §4 showed otherwise — the
old configs were written for a repo where every platform had its own entry
point, so they hard-code assumptions this design removes. Each rewrite below
opens with the specific defect it fixes; the short version:

| Config | Why it cannot be carried over |
|---|---|
| wezterm | `default_prog = powershell.exe` unconditionally — launches nothing on macOS or Linux. Now the terminal on all four platforms. |
| tmux | Sources tpm from `~/.tmux/plugins/`, a path nothing in this repo creates. Every plugin line is inert. |
| lazygit | 60 lines of commented-out themes and no non-theme settings at all. No editor, no pager, no XDG pin for Windows. |
| starship | Defines five palettes and selects one, then configures zero modules — it is a colour file, not a prompt. |
| bat | Ships four Catppuccin `.tmTheme` files that are dead weight: the theme is `OneHalfDark` and nothing ever runs `bat cache --build`. |
| vscode | Targets `~/.config/Code/User`, which is the correct path on **Linux only** — see §7.43. |
| zed | Fine as config, but the source directory also holds `prompts/*.mdb` and `conversations/` — runtime state, same trap as §7.34. |
| workmux | Was deferred with no schema. Schema now confirmed; §7.25 is a real file. |
| tmux-sessionizer | Branches on `uname` to pick one hard-coded project dir per OS. |
| statusline (ps1) | Builds its output string and never prints it. The Windows statusline is blank. |
| statusline (sh) | Forks `jq` ten times per refresh, at `refreshInterval: 1`. |

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
{{- $theme := promptStringOnce . "theme" "Colour scheme (onedark/catppuccin-mocha/dracula/rose-pine)" "onedark" -}}

[data]
    role  = {{ $role | quote }}
    work  = {{ $work }}
    email = {{ $email | quote }}
    theme = {{ $theme | quote }}

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

`theme` has eleven consumers and is the subject of §7.35. Unlike `role` and
`work` it is expected to change over a machine's life, so §7.35 also ships a
`theme` command that edits this file and re-applies rather than making that a
manual edit.

## 7.6 `home/.chezmoiignore`

The load-bearing file — keep it a flat table. Patterns are target-relative; listed paths are never written. `README.md`, `docs/`, and `.pre-commit-config.yaml` need no entries: `.chezmoiroot` puts them outside the source tree.

```
{{- $desktop := eq .role "desktop" -}}

{{ if not $desktop }}
# headless: GUI configs never materialize
.config/wezterm
.config/zed
.config/Code
Library/
AppData/
.vsvimrc
.ideavimrc
{{ end }}

# VS Code's config directory is a different absolute path on each platform, so
# the source tree carries all three and excludes the two that do not apply.
# The content lives once in .chezmoitemplates/vscode/ — see §7.43.
{{ if ne .chezmoi.os "linux" }}
.config/Code
{{ end }}
{{ if ne .chezmoi.os "darwin" }}
Library/
{{ end }}
{{ if ne .chezmoi.os "windows" }}
AppData/
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

## 7.7 `home/.chezmoiexternal.toml.tmpl`

Replaces tmux-plugin submodules — **and tpm itself**. The old `tmux.conf` ran
`run '~/.tmux/plugins/tpm/tpm'`, which then cloned five more repos at first
launch behind a manual `prefix-I`. Two problems: the path does not match where
chezmoi puts things, and "clone at runtime after a keypress" is exactly the
non-idempotent bootstrap §1.3 is about. Fetching each plugin as an external and
sourcing it directly from `tmux.conf` (§7.37) removes both, and `refreshPeriod`
gives plugin updates the same cadence as everything else here.

```toml
[".config/tmux/plugins/tmux-resurrect"]
    type = "git-repo"
    url = "https://github.com/tmux-plugins/tmux-resurrect.git"
    refreshPeriod = "168h"

[".config/tmux/plugins/tmux-continuum"]
    type = "git-repo"
    url = "https://github.com/tmux-plugins/tmux-continuum.git"
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

Three of the old five tmux plugins are not here, each for a reason:

| Dropped | Replaced by |
|---|---|
| `tmux-plugins/tpm` | externals, above |
| `tmux-plugins/tmux-yank` | `set -g set-clipboard on`. tmux emits OSC 52 and WezTerm honours it, including over SSH — which is the whole point of standardising on one terminal (§3). |
| `christoomey/vim-tmux-navigator` | `M-hjkl` (§7.37). The plugin needs a matching plugin on the Neovim side; the hand-rolled config has none, so only half the pair was ever installed. |
| `craftzdog/tmux-claude-session-manager` | workmux (§7.25), which tracks agent status natively and owns the window layout. Running both means two things writing the same window names. |

## 7.8 `home/.chezmoidata/packages.yaml`

The tool inventory on one screen. Install scripts render their lists from this, so `run_onchange_` re-triggers automatically on any edit.

Two additions since the first draft, both forced by the configs below:

- **`git-delta`.** §7.39 sets it as lazygit's pager and §7.22 as git's. Same
  package name in Homebrew and apt (`git-delta`), binary `delta`.
- **A Nerd Font.** `20-aliases.sh` runs eza with `--icons=always`, §7.39 sets
  `nerdFontsVersion: "3"`, and §7.36 names the font explicitly. Nothing in the
  first draft ever installed one, so every glyph would have been a tofu box on
  a fresh machine. It is a `desktop`-only concern — a headless box renders no
  glyphs — so it lives under `desktop`, not `core`.

```yaml
packages:
  # Present and current in every system package manager.
  core:
    - git
    - git-delta
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
      casks:
        - wezterm
        - visual-studio-code
        - zed
        - font-jetbrains-mono-nerd-font
    linux:
      # WezTerm is not in Debian's default repos — see §7.28.
      # The font is fetched from the nerd-fonts release in §7.30 instead;
      # apt has no JetBrainsMono Nerd Font package.
      apt: [wezterm, fontconfig]
    windows:
      winget:
        - wez.wezterm
        - Microsoft.VisualStudioCode
        - Zed.Zed
        - DEVCOM.JetBrainsMonoNerdFont
      scoop:  [opencode]

  # Ported wholesale from config/vscode/extensions.txt. The first draft listed
  # two of these; the other nineteen would have silently vanished at migration.
  # ms-vscode-remote.vscode-remote-extensionpack subsumes remote-ssh.
  # zhuangtongfa.material-theme is deliberately absent — the colour theme
  # extension comes from the active themes.yaml row instead (§7.32, §7.35).
  vscode_extensions:
    - aaron-bond.better-comments
    - alefragnani.project-manager
    - anthropic.claude-code
    - dbcode.dbcode
    - editorconfig.editorconfig
    - github.vscode-github-actions
    - github.vscode-pull-request-github
    - humao.rest-client
    - ms-azuretools.vscode-containers
    - ms-python.python
    - ms-vscode-remote.vscode-remote-extensionpack
    - ms-vscode.cpptools-extension-pack
    - pkief.material-icon-theme
    - pkief.material-product-icons
    - redhat.vscode-xml
    - redhat.vscode-yaml
    - rust-lang.rust-analyzer
    - vmware.vscode-boot-dev-pack
    - vscjava.vscode-java-pack
    - vscodevim.vim

  mise_runtimes:
    - node@lts
    - python@3.14
    - rust@stable
```

`packages.desktop.*` is consumed only where `.role` is `desktop`, so a headless
box installs neither WezTerm nor a font nor any VS Code extension. That is the
role split doing its job — it needs no extra `.chezmoiignore` entry.

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

## 7.14 `home/dot_config/sh/10-env.sh.tmpl`

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

# Pinned explicitly rather than relying on XDG discovery, which makes these
# immune to the Windows XDG question entirely.
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"

# lazygit is the one tool §5 flagged as unverified on Windows: it falls back to
# %APPDATA%\lazygit. LG_CONFIG_FILE is an absolute override that outranks every
# discovery rule, so pinning it here settles the question instead of deferring
# it to step 3. The PowerShell profile (§7.26) sets the same variable.
export LG_CONFIG_FILE="$XDG_CONFIG_HOME/lazygit/config.yml"

export EZA_COLORS="uu=36:uR=31:un=35:gu=37:da=2;34:ur=34:uw=95:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:xx=95"

# Theme colours for the fzf UI, rendered from §7.35. Kept separate from
# FZF_DEFAULT_OPTS, which 30-tools.sh assembles: colours are static, the
# preview command is not. bg:-1 keeps the terminal's own background, so fzf
# stays transparent over whatever wezterm is doing.
export FZF_THEME_COLORS="--color=fg:{{ $p.fg }},bg:-1,hl:{{ $p.blue }}\
,fg+:{{ $p.fg_bright }},bg+:{{ $p.surface }},hl+:{{ $p.blue }}\
,info:{{ $p.green }},prompt:{{ $p.magenta }},pointer:{{ $p.red }}\
,marker:{{ $p.yellow }},spinner:{{ $p.cyan }},header:{{ $p.grey }},border:{{ $p.grey }}"
```

This makes `10-env.sh` the one file in `sh/` that is a template — it becomes
`dot_config/sh/10-env.sh.tmpl` and opens with the §7.35 header:

```
{{- $t := index .themes (.theme | default "onedark") -}}
{{- $p := $t.palette -}}
```

§7.16 gains one line to consume it — and stays a plain `.sh`, because it
references the variable rather than the palette:

```sh
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default $FZF_THEME_COLORS"
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

The first draft of this section was four blocks long and silently dropped every
alias, both difftool definitions, and the `clwt` bare-clone helper from
`git/gitconfig.symlink`. Those come back here, plus delta as the pager.

```
[user]
    name  = Brian Silver
    email = {{ .email }}

[core]
    editor = nvim
    ignorecase = false
    pager = delta
{{- if eq .chezmoi.os "windows" }}
    autocrlf = input
{{- end }}

[init]
    defaultBranch = main

[pull]
    rebase = true
[push]
    default = simple
    autoSetupRemote = true
[fetch]
    prune = true
[submodule]
    recurse = true
[rerere]
    # Remember conflict resolutions. Worth it with the worktree-heavy workflow
    # in §7.25 — the same conflict comes back on every rebase of every worktree.
    enabled = true
    autoupdate = true
[merge]
    conflictstyle = zdiff3
    tool = nvimdiff
    prompt = false
[diff]
    algorithm = histogram
    colorMoved = default
    tool = nvimdiff
[color]
    ui = auto

[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    line-numbers = true
    syntax-theme = OneHalfDark
    dark = true

[difftool "nvimdiff"]
    cmd = nvim -c "packadd nvim.difftool" -c "DiffTool $LOCAL $REMOTE"
[mergetool "nvimdiff4"]
    cmd = nvim -d $LOCAL $BASE $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'

[alias]
    hist = log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all
    llog = log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative
    clbare = clone --bare
    setupbare = "!git config remote.origin.fetch \"+refs/heads/*:refs/remotes/origin/*\" && git fetch origin"
    clwt = "!f() { url=$1; basename=${url##*/}; name=${2:-${basename%.git}}; mkdir \"$name\"; cd \"$name\"; git clone --bare \"$url\" .bare; echo \"gitdir: ./.bare\" > .git; git config remote.origin.fetch \"+refs/heads/*:refs/remotes/origin/*\"; git fetch origin; }; f"

[include]
    # Untracked. Work signing keys, internal URLs, credential helpers.
    # Git silently ignores a missing include, so personal machines need no file.
    path = ~/.gitconfig.local
```

Two corrections carried in from the old file rather than copied blindly:

- `clwt` had `${basename%.}` where it meant `${basename%.git}`. `%.` strips a
  trailing literal dot, so cloning `foo.git` produced a directory called
  `foo.git`. Fixed above.
- `[core] autocrlf = input` was set unconditionally. On Windows `input` commits
  LF but checks out LF too, which is the one platform where that is usually not
  wanted; it is now inside the Windows guard where the original template put it,
  and it is worth revisiting in step 3 if any tooling complains.

Delta replaces no existing setting — the old config had no pager at all, so diffs
came out of `less` unstyled. `syntax-theme` names a bat theme, which is why §7.41
keeps `OneHalfDark` rather than switching to a custom One Dark `.tmTheme`.

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

No longer deferred — the schema is confirmed against upstream. workmux reads
`~/.config/workmux/config.yaml`, XDG-native on every Unix, so no pinning is
needed. Unix only; §7.6 already excludes it on Windows.

```yaml
# Nerd Font glyphs in the dashboard and sidebar. Safe because the font is a
# desktop package (§7.8) — but the sidebar also renders on headless boxes over
# SSH, where the *local* terminal supplies the font. WezTerm everywhere (§3)
# is what makes this true, so it is set unconditionally.
nerdfont: true

agent: claude
agents:
  # `workmux add -a yolo` for a sandboxed no-prompt run.
  yolo:
    type: claude
    command: claude
    args: ["--dangerously-skip-permissions"]
  cod: "codex"

base_branch: auto
merge_strategy: rebase
merge_keep: false

# Worktrees out of the repo, not beside it. `{project}` expands to the repo
# name, so every worktree for every project lives under one root that is
# trivially greppable and trivially deletable.
worktree_dir: ~/.local/state/workmux/{project}
worktree_naming: basename

mode: window
window_prefix: "wm-"
window_placement: after_current
status_format: true

status_icons:
  working: "󰚩"
  waiting: "󰭹"
  done: "󰄬"

# Agent on the left with focus, a shell on the right for tests and git.
panes:
  - command: <agent>
    name: agent
    focus: true
  - split: horizontal
    name: shell
    percentage: 35

sidebar:
  position: left
  width: 32
  layout: tiles

# Everything a worktree needs that git does not carry. Both lists are
# deliberately short and non-secret-bearing in themselves — .env is copied, not
# symlinked, so a worktree cannot corrupt the parent's environment.
files:
  copy:
    - .env
    - .env.local
  symlink:
    - node_modules
    - target
    - .venv

post_create:
  - direnv allow 2>/dev/null || true

auto_name:
  command: "claude -p"

sandbox:
  enabled: false
```

Three things this leaves alone on purpose:

- **`main_branch`** is unset, so workmux auto-detects. Hard-coding `main` breaks
  the handful of work repos still on `master`.
- **`sandbox.enabled: false`.** The container backend pulls an image and the
  Lima backend is macOS-only; neither belongs in the first-boot path. Turn it on
  per-project in `.workmux.yaml` once a project actually needs it.
- **`layouts`** — named multi-agent layouts are per-project by nature.

Per-repo `.workmux.yaml` files live in project repos and are never managed here.
They can pull these values in with the literal string `"<global>"` inside any
hook or file list, which is why `post_create` here stays to one universal line.

`workmux setup` must be run once per machine to install its tmux status hooks
and Claude Code integration. It is not in §7.30 because it is not an install
step — §7.33 covers the shell completions, and the status hooks are what
`status_format: true` above negotiates at runtime.

## 7.26 `home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`

The one irreducible non-XDG path. Documents may be redirected into OneDrive — check `$PROFILE` on the machine in step 3 and adjust the source path if it differs.

§7.6 excludes `.config/sh` and `.config/zsh` on Windows, which means this file is
not a thin veneer over the POSIX layer — it *is* the entire Windows shell. The
first draft gave it five lines and no history, no keybinds, no aliases, and no
XDG variables. It mirrors `10-env.sh`, `20-aliases.sh`, `30-tools.sh`,
`10-history.zsh`, and `20-keybinds.zsh`, in that order, so the two halves of the
repo stay legible against each other.

```
# --- env (mirrors 10-env.sh) -------------------------------------------------
# run_onchange_before_10-packages-windows.ps1 sets these at User scope so GUI
# apps see them; re-set here so a shell opened before that ran is still correct.
$env:XDG_CONFIG_HOME = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { "$env:USERPROFILE\.config" }
$env:XDG_DATA_HOME   = if ($env:XDG_DATA_HOME)   { $env:XDG_DATA_HOME }   else { "$env:USERPROFILE\.local\share" }
$env:XDG_CACHE_HOME  = if ($env:XDG_CACHE_HOME)  { $env:XDG_CACHE_HOME }  else { "$env:USERPROFILE\.cache" }
$env:XDG_STATE_HOME  = if ($env:XDG_STATE_HOME)  { $env:XDG_STATE_HOME }  else { "$env:USERPROFILE\.local\state" }

$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:STARSHIP_CONFIG = "$env:XDG_CONFIG_HOME\starship.toml"
$env:MISE_CONFIG_DIR = "$env:XDG_CONFIG_HOME\mise"
$env:LG_CONFIG_FILE  = "$env:XDG_CONFIG_HOME\lazygit\config.yml"

# --- aliases (mirrors 20-aliases.sh) -----------------------------------------
# Set-Alias cannot take arguments, so anything with flags is a function.
# Remove-Alias guards: PowerShell ships built-in ls/cat/rm aliases that win.
Set-Alias -Name vim -Value nvim
Set-Alias -Name g   -Value git
Set-Alias -Name c   -Value Clear-Host

if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Alias ls -Force -ErrorAction SilentlyContinue
    function ls { eza --color=always --icons=always --git @args }
    function l  { eza --color=always --icons=always --git @args }
    function ll { eza --color=always --icons=always --git -lagSX @args }
    function lt { eza --color=always --tree --level=2 --icons=always --long --git @args }
}
if (Get-Command lazygit -ErrorAction SilentlyContinue) { function gg { lazygit @args } }

function ..   { Set-Location .. }
function ...  { Set-Location ..\.. }
function gst  { git status @args }
function ga   { git add @args }
function gc   { git commit --verbose @args }
function gd   { git diff @args }
function gl   { git pull @args }
function gp   { git push @args }
function gco  { git checkout @args }
function glog { git log --oneline --decorate --graph @args }

# --- history and keybinds (mirrors 10-history.zsh / 20-keybinds.zsh) ---------
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -MaximumHistoryCount 100000
Set-PSReadLineKeyHandler -Key 'Ctrl+p' -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key 'Ctrl+n' -Function HistorySearchForward

# Vi mode hides which mode you are in; without this the prompt is a guess.
Set-PSReadLineOption -ViModeIndicator Cursor

# --- tools (mirrors 30-tools.sh) ---------------------------------------------
foreach ($t in 'starship', 'zoxide', 'mise') {
    if (Get-Command $t -ErrorAction SilentlyContinue) {
        switch ($t) {
            'starship' { Invoke-Expression (&starship init powershell) }
            'zoxide'   { Invoke-Expression (& { (zoxide init powershell | Out-String) }) }
            'mise'     { Invoke-Expression (& { (mise activate pwsh | Out-String) }) }
        }
    }
}

# --- machine-local (mirrors 99-local.sh) -------------------------------------
$local_profile = "$env:XDG_CONFIG_HOME\powershell\local.ps1"
if (Test-Path $local_profile) { . $local_profile }
```

`fzf` has no PowerShell key-binding story worth the dependency (`PSFzf` is a
separate module and would need its own install step), so `Ctrl-r` stays on
PSReadLine's `HistorySearchBackward` above. On Windows the interactive shell is
WSL anyway; this profile exists so the native side is usable, not preferred.

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
{{- $t := index .themes (.theme | default "onedark") -}}
#!/bin/sh
set -eu

# extensions: {{ .packages.vscode_extensions | join " " }}
# theme extension: {{ $t.vscode.extension }}
command -v code >/dev/null 2>&1 || exit 0
{{- range .packages.vscode_extensions }}
code --install-extension {{ . }} --force
{{- end }}
{{- if $t.vscode.extension }}
# The colour theme named in settings.json (§7.43) is inert without this.
code --install-extension {{ $t.vscode.extension }} --force
{{- end }}
{{- end }}
```

The theme extension is installed here rather than listed in
`packages.vscode_extensions` so that switching schemes installs the new theme
automatically — and so the two facts (which theme, which extension provides it)
stay in one row of `themes.yaml`. `zhuangtongfa.material-theme` is therefore
removed from the static list in §7.8; it arrives via the `onedark` row.

Switching theme changes the rendered comment at the top, which is what makes
`run_onchange_` fire — the same trick as §7.41's `# theme:` line.

Windows is excluded because this is a `.sh` script. If you want extensions installed natively on Windows too, add a `.ps1` sibling in step 3; otherwise VS Code's own Settings Sync covers it.

## 7.33 `home/run_onchange_after_22-completions.sh.tmpl`

workmux generates completions rather than shipping them.

```
{{- if ne .chezmoi.os "windows" -}}
#!/bin/sh
set -eu

COMPDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
mkdir -p "$COMPDIR"

# `|| true` on each: a tool that is installed but whose completions subcommand
# fails must not abort the whole apply under `set -e`.
command -v workmux >/dev/null 2>&1 && { workmux completions zsh > "$COMPDIR/_workmux" || true; }
command -v gh      >/dev/null 2>&1 && { gh completion -s zsh   > "$COMPDIR/_gh"      || true; }
command -v mise    >/dev/null 2>&1 && { mise completion zsh    > "$COMPDIR/_mise"    || true; }
{{- end }}
```

fzf, zoxide, and starship are absent because their `init`/`--zsh` hooks in
§7.16 install completions themselves at shell startup. lazygit, bat, eza, and
delta ship none.

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

## 7.35 `home/.chezmoidata/themes.yaml` — the `theme` variable

### Why this is a variable and not a palette

Eleven files encode a colour scheme: wezterm, the tmux theme, lazygit,
starship, fzf (via `10-env.sh`), bat, delta (via `.gitconfig`), nvim, zed,
vscode, and the two statusline scripts. No two share a format. Writing One Dark
into all eleven by hand and hoping they stay in step is the same class of
problem as `bootstrap.sh` branching on platform in eleven places — which is what
§1 says this rebuild exists to stop doing.

So colour becomes the third machine variable, alongside `role` and `work`:

```
role  = desktop | headless      # what gets installed
work  = true | false            # whose Claude config wins
theme = onedark | catppuccin-mocha | dracula | rose-pine
```

`chezmoi apply` re-renders all eleven from one row of data. Switching schemes is
one edit and one apply, not an afternoon.

The four themes are not arbitrary — they are the four that were already in the
old repo, three of them commented out in `config/lazygit/config.yml` and two
more sitting unused in `config/starship.toml` and `config/bat/themes/`. This
promotes an existing habit into a mechanism instead of inventing one.

### Two kinds of tool

The split that makes this work:

| Kind | Tools | How the theme reaches it |
|---|---|---|
| **Palette-driven** | wezterm, tmux, lazygit, starship, fzf | chezmoi renders hex values straight into the config from `themes.yaml` |
| **Name-driven** | bat, delta, nvim, vscode, zed | the tool has its own theme registry; chezmoi renders a *name*, and sometimes has to install a plugin or extension first |

Name-driven tools are the expensive half: selecting `catppuccin-mocha` in VS
Code means installing `Catppuccin.catppuccin-vsc` before the name resolves. So
each theme row carries not just a name per tool but whatever has to be installed
to make that name valid, and §7.32 / §7.50 / §7.45 consume those fields.

### The file

```yaml
# The colour scheme registry. `theme` in ~/.config/chezmoi/chezmoi.toml selects
# one row; every themed config renders from it. To add a scheme, add a row —
# no config file below needs to change.
#
# palette keys are semantic, not literal: `red` means "errors and unstaged
# changes", not "the reddest colour in the scheme". ansi/brights are the
# 16-colour terminal set, which is usually more saturated than the syntax
# colours so 16-colour TUIs stay legible.
themes:
  onedark:
    name: "One Dark"
    dark: true
    palette:
      bg:        "#282c34"
      bg_alt:    "#21252b"
      surface:   "#2c313a"
      fg:        "#abb2bf"
      fg_bright: "#d7dae0"
      grey:      "#5c6370"
      black:     "#3f4451"
      red:       "#e06c75"
      green:     "#98c379"
      yellow:    "#e5c07b"
      orange:    "#d19a66"
      blue:      "#61afef"
      magenta:   "#c678dd"
      cyan:      "#56b6c2"
    ansi:    ["#3f4451", "#e05561", "#8cc265", "#d18f52", "#4aa5f0", "#c162de", "#42b3c2", "#d7dae0"]
    brights: ["#4f5666", "#ff616e", "#a5e075", "#f0a45d", "#4dc4ff", "#de73ff", "#4cd1e0", "#e6e6e6"]
    bat:     { theme: "OneHalfDark" }          # built in, no external needed
    nvim:    { plugin: "https://github.com/navarasu/onedark.nvim", colorscheme: "onedark" }
    vscode:  { extension: "zhuangtongfa.material-theme", name: "One Dark Pro Darker" }
    zed:     { extension: "", dark: "One Dark", light: "One Light" }

  catppuccin-mocha:
    name: "Catppuccin Mocha"
    dark: true
    palette:
      bg:        "#1e1e2e"
      bg_alt:    "#181825"
      surface:   "#313244"
      fg:        "#cdd6f4"
      fg_bright: "#f5e0dc"
      grey:      "#6c7086"
      black:     "#45475a"
      red:       "#f38ba8"
      green:     "#a6e3a1"
      yellow:    "#f9e2af"
      orange:    "#fab387"
      blue:      "#89b4fa"
      magenta:   "#cba6f7"
      cyan:      "#94e2d5"
    ansi:    ["#45475a", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#cba6f7", "#94e2d5", "#bac2de"]
    brights: ["#585b70", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#cba6f7", "#94e2d5", "#a6adc8"]
    bat:     { theme: "Catppuccin Mocha", tmtheme: "https://github.com/catppuccin/bat.git" }
    nvim:    { plugin: "https://github.com/catppuccin/nvim", colorscheme: "catppuccin-mocha" }
    vscode:  { extension: "Catppuccin.catppuccin-vsc", name: "Catppuccin Mocha" }
    zed:     { extension: "catppuccin", dark: "Catppuccin Mocha", light: "Catppuccin Latte" }

  dracula:
    name: "Dracula"
    dark: true
    palette:
      bg:        "#282a36"
      bg_alt:    "#21222c"
      surface:   "#44475a"
      fg:        "#f8f8f2"
      fg_bright: "#ffffff"
      grey:      "#6272a4"
      black:     "#21222c"
      red:       "#ff5555"
      green:     "#50fa7b"
      yellow:    "#f1fa8c"
      orange:    "#ffb86c"
      blue:      "#bd93f9"
      magenta:   "#ff79c6"
      cyan:      "#8be9fd"
    ansi:    ["#21222c", "#ff5555", "#50fa7b", "#f1fa8c", "#bd93f9", "#ff79c6", "#8be9fd", "#f8f8f2"]
    brights: ["#6272a4", "#ff6e6e", "#69ff94", "#ffffa5", "#d6acff", "#ff92df", "#a4ffff", "#ffffff"]
    bat:     { theme: "Dracula" }              # built in
    nvim:    { plugin: "https://github.com/Mofiqul/dracula.nvim", colorscheme: "dracula" }
    vscode:  { extension: "dracula-theme.theme-dracula", name: "Dracula Theme" }
    zed:     { extension: "dracula", dark: "Dracula", light: "Dracula" }

  rose-pine:
    name: "Rosé Pine"
    dark: true
    palette:
      bg:        "#191724"
      bg_alt:    "#1f1d2e"
      surface:   "#26233a"
      fg:        "#e0def4"
      fg_bright: "#e0def4"
      grey:      "#6e6a86"
      black:     "#26233a"
      red:       "#eb6f92"
      green:     "#31748f"
      yellow:    "#f6c177"
      orange:    "#ebbcba"
      blue:      "#9ccfd8"
      magenta:   "#c4a7e7"
      cyan:      "#9ccfd8"
    ansi:    ["#26233a", "#eb6f92", "#31748f", "#f6c177", "#9ccfd8", "#c4a7e7", "#ebbcba", "#e0def4"]
    brights: ["#6e6a86", "#eb6f92", "#31748f", "#f6c177", "#9ccfd8", "#c4a7e7", "#ebbcba", "#e0def4"]
    bat:     { theme: "rose-pine", tmtheme: "https://github.com/rose-pine/tm-theme.git" }
    nvim:    { plugin: "https://github.com/rose-pine/neovim", colorscheme: "rose-pine" }
    vscode:  { extension: "mvllow.rose-pine", name: "Rosé Pine" }
    zed:     { extension: "rose-pine-theme", dark: "Rosé Pine", light: "Rosé Pine Dawn" }
```

### The prompt

§7.5 gains one line. `promptStringOnce` means an existing machine is never
re-asked; changing theme later is an edit to `~/.config/chezmoi/chezmoi.toml`.

```
{{- $theme := promptStringOnce . "theme" "Colour scheme (onedark/catppuccin-mocha/dracula/rose-pine)" "onedark" -}}
```

```
[data]
    role  = {{ $role | quote }}
    work  = {{ $work }}
    email = {{ $email | quote }}
    theme = {{ $theme | quote }}
```

### The header every themed template starts with

```
{{- $t := index .themes (.theme | default "onedark") -}}
{{- $p := $t.palette -}}
```

`| default "onedark"` matters: a machine initialised before this section existed
has no `theme` key, and `index .themes ""` returns nil, which makes every
`$p.bg` below fail with a nil-map error rather than anything legible.

### What this changes in the files below

Nine files pick up a `.tmpl` suffix. The suffix is the only structural change —
each file's body is unchanged except that hex literals become `{{ $p.<key> }}`.

| File | Becomes | Reads |
|---|---|---|
| `dot_config/wezterm/wezterm.lua` | `.lua.tmpl` | `$p`, `$t.ansi`, `$t.brights`, `$t.name` |
| `dot_config/tmux/themes/onedark.conf` | `dot_config/tmux/themes/theme.conf.tmpl` | `$p` |
| `dot_config/lazygit/config.yml` | `.yml.tmpl` | `$p` |
| `dot_config/starship.toml` | `.toml.tmpl` | `$p` |
| `dot_config/bat/config` | `config.tmpl` | `$t.bat.theme` |
| `dot_config/sh/10-env.sh` | `.sh.tmpl` | `$p` (fzf colours) |
| `dot_gitconfig.tmpl` | *(already a template)* | `$t.bat.theme` for delta |
| `dot_config/nvim/lua/theme.lua` | `.lua.tmpl` | `$t.nvim` |
| `dot_config/zed/settings.json` | `.json.tmpl` | `$t.zed` |
| `.chezmoitemplates/vscode/settings.json` | *(already included via a shim)* | `$t.vscode.name` |
| `.chezmoiexternal.toml` | `.toml.tmpl` | `$t.bat.tmtheme` |

The tmux theme file is renamed from `onedark.conf` to `theme.conf`, and
`tmux.conf` drops its `@theme` line to `set -g @theme "theme"`. The old
mechanism — one `.conf` per scheme, switch by editing a variable and hitting
`prefix-r` — is now redundant with the chezmoi-level variable, and keeping both
means two places to change a colour. Losing the live `prefix-r` swap is the
price; `theme <name>` (below) is two seconds slower and covers all eleven tools
instead of one.

### `home/dot_local/bin/executable_theme` — the switcher

Editing TOML by hand to change a colour scheme is the kind of friction that
means it never gets used.

```sh
#!/bin/sh
# Switch the colour scheme across every tool.
#   theme            list available schemes, mark the active one
#   theme dracula    switch to dracula and re-apply
set -eu

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"
current=$(chezmoi data | jq -r '.theme // "onedark"')

if [ $# -eq 0 ]; then
    chezmoi data | jq -r '.themes | keys[]' | while read -r t; do
        if [ "$t" = "$current" ]; then printf '* %s\n' "$t"; else printf '  %s\n' "$t"; fi
    done
    exit 0
fi

want=$1
chezmoi data | jq -e --arg t "$want" '.themes | has($t)' >/dev/null 2>&1 || {
    echo "theme: unknown scheme '$want'" >&2
    exit 1
}

# The data key may not exist yet on a machine initialised before themes did.
if grep -q '^[[:space:]]*theme[[:space:]]*=' "$CONFIG"; then
    sed -i.bak "s|^\([[:space:]]*\)theme[[:space:]]*=.*|\1theme = \"$want\"|" "$CONFIG"
    rm -f "$CONFIG.bak"
else
    printf '    theme = "%s"\n' "$want" >> "$CONFIG"
fi

chezmoi apply
echo "theme: $want — restart tmux (prefix-r) and any running editor"
```

`sed -i.bak` then `rm` rather than bare `sed -i`: GNU sed accepts `-i` with no
argument and BSD sed does not, and this script runs on both.

### What a theme switch does not reach

Honest limits, all of them the same shape — a process that read its config at
startup:

- **Running tmux servers** need `prefix-r`. The echoed reminder covers it.
- **Running editors** need a restart; VS Code and Zed both re-read theme
  settings live, but only if the extension is already installed.
- **A VS Code or Zed theme extension** installs on the *next* `chezmoi apply`
  via §7.32, which is the same apply — but VS Code has to be restarted for a
  newly installed extension to register its theme.
- **bat's cache**, for the two schemes that need a `.tmtheme`. See §7.41.
- **Neovim plugins** are installed by `vim.pack` on next launch, not by chezmoi.

None of these is fixable from the chezmoi side; they are all "the program is
already running". Worth stating so the first switch does not look broken.

## 7.36 `home/dot_config/wezterm/wezterm.lua.tmpl`

Desktop only. The old file was written when WezTerm was the Windows terminal and
Alacritty/Ghostty covered Unix: it sets `default_prog = { "powershell.exe" }`
unconditionally, so on macOS or Linux it would fail to spawn a shell at all.
§3 makes WezTerm the terminal everywhere, so the platform branch has to be real.

The scheme is generated from §7.35 rather than named, so it works for all four
themes without depending on WezTerm shipping a builtin by that name — which for
`onedark` it does not.

```lua
{{- $t := index .themes (.theme | default "onedark") -}}
{{- $p := $t.palette -}}
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

local triple = wezterm.target_triple
local is_windows = triple:find("windows") ~= nil
local is_mac = triple:find("darwin") ~= nil

-- ---------------------------------------------------------------------------
-- Colours — generated from .chezmoidata/themes.yaml (§7.35)
-- ---------------------------------------------------------------------------
config.color_schemes = {
  [{{ $t.name | quote }}] = {
    foreground     = {{ $p.fg | quote }},
    background     = {{ $p.bg | quote }},
    cursor_bg      = {{ $p.blue | quote }},
    cursor_fg      = {{ $p.bg | quote }},
    cursor_border  = {{ $p.blue | quote }},
    selection_fg   = {{ $p.fg_bright | quote }},
    selection_bg   = {{ $p.surface | quote }},
    scrollbar_thumb = {{ $p.grey | quote }},
    split          = {{ $p.black | quote }},
    ansi    = { {{ range $i, $c := $t.ansi }}{{ if $i }}, {{ end }}{{ $c | quote }}{{ end }} },
    brights = { {{ range $i, $c := $t.brights }}{{ if $i }}, {{ end }}{{ $c | quote }}{{ end }} },
    tab_bar = {
      background = {{ $p.bg_alt | quote }},
      active_tab         = { bg_color = {{ $p.blue | quote }},    fg_color = {{ $p.bg | quote }}, intensity = "Bold" },
      inactive_tab       = { bg_color = {{ $p.bg_alt | quote }},  fg_color = {{ $p.grey | quote }} },
      inactive_tab_hover = { bg_color = {{ $p.surface | quote }}, fg_color = {{ $p.fg | quote }} },
      new_tab            = { bg_color = {{ $p.bg_alt | quote }},  fg_color = {{ $p.grey | quote }} },
      new_tab_hover      = { bg_color = {{ $p.surface | quote }}, fg_color = {{ $p.fg | quote }} },
    },
  },
}
config.color_scheme = {{ $t.name | quote }}

-- ---------------------------------------------------------------------------
-- Font — installed as a desktop package in §7.8
-- ---------------------------------------------------------------------------
config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",
  "Symbols Nerd Font Mono",
  "Noto Color Emoji",
})
-- Retina and 1080p disagree by about two points at the same apparent size.
config.font_size = is_mac and 13.0 or 11.0
config.line_height = 1.05
config.adjust_window_size_when_changing_font_size = false

-- ---------------------------------------------------------------------------
-- Window and tabs
-- ---------------------------------------------------------------------------
-- tmux owns tabs on Unix, so the bar is only ever seen on native Windows or in
-- the brief moment before tmux attaches. Keep it, keep it out of the way.
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

config.window_padding = { left = 6, right = 6, top = 4, bottom = 0 }
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.animation_fps = 1
config.cursor_blink_rate = 500
config.default_cursor_style = "BlinkingBlock"
-- tmux sessions survive the window closing; the prompt asks about nothing.
config.window_close_confirmation = "NeverPrompt"
config.check_for_updates = false

-- ---------------------------------------------------------------------------
-- Shell and domains
-- ---------------------------------------------------------------------------
-- On Unix, default_prog is deliberately unset: WezTerm spawns the login shell,
-- which is zsh where chsh worked and bash otherwise — and .bashrc (§7.11)
-- execs zsh in that case. Setting it here would bypass that handoff.
if is_windows then
  -- WSL is the real shell on Windows; pwsh is the fallback in the launcher.
  config.wsl_domains = wezterm.default_wsl_domains()
  if #config.wsl_domains > 0 then
    config.default_domain = config.wsl_domains[1].name
  else
    config.default_prog = { "pwsh.exe", "-NoLogo" }
  end
end

local launch_menu = {}
if is_windows then
  table.insert(launch_menu, { label = "PowerShell", args = { "pwsh.exe", "-NoLogo" } })
  table.insert(launch_menu, { label = "Cmd", args = { "cmd.exe", "/NoLogo" } })
  for _, dom in ipairs(config.wsl_domains or {}) do
    table.insert(launch_menu, { label = dom.name, domain = { DomainName = dom.name } })
  end
  -- Visual Studio developer shells, discovered rather than hard-coded.
  for _, vsvers in ipairs(wezterm.glob("Microsoft Visual Studio/20*/*", "C:/Program Files")) do
    local version = vsvers:gsub("Microsoft Visual Studio/", ""):gsub("/", " ")
    local root = "C:/Program Files/" .. vsvers .. "/VC/Auxiliary/Build"
    for _, script in ipairs(wezterm.glob("vcvars*.bat", root)) do
      local arch = script:gsub("vcvars", ""):gsub("%.bat", "")
      if arch ~= "all" then
        table.insert(launch_menu, {
          label = "VS " .. version .. " DevTools " .. arch,
          args = { "cmd.exe", "/k", root .. "/" .. script },
        })
      end
    end
  end
else
  table.insert(launch_menu, { label = "zsh", args = { "zsh", "-l" } })
  table.insert(launch_menu, { label = "bash", args = { "bash", "-l" } })
  table.insert(launch_menu, { label = "tmux", args = { "zsh", "-lc", "tmux new -A -s main" } })
end
config.launch_menu = launch_menu

-- ---------------------------------------------------------------------------
-- Keys — every binding is CTRL|SHIFT so none of them collide with the tmux
-- prefix (C-a), readline, or a TUI running inside the pane.
-- ---------------------------------------------------------------------------
-- Light/dark flip. The light side is a WezTerm builtin rather than a second
-- generated scheme: themes.yaml carries one palette per row, and a light
-- variant for all four is four more palettes to keep in step for a keybinding
-- that gets used on a sunny afternoon.
wezterm.on("toggle-colorscheme", function(window, _)
  local dark = {{ $t.name | quote }}
  local overrides = window:get_config_overrides() or {}
  overrides.color_scheme = (overrides.color_scheme == "OneHalfLight") and dark or "OneHalfLight"
  window:set_config_overrides(overrides)
end)

config.keys = {
  { key = "e", mods = "CTRL|SHIFT", action = act.EmitEvent("toggle-colorscheme") },
  { key = "f", mods = "CTRL|SHIFT", action = act.ToggleFullScreen },
  { key = "Space", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS|DOMAINS|FUZZY" }) },
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
  { key = "0", mods = "CTRL|SHIFT", action = act.ResetFontSize },
}

-- ---------------------------------------------------------------------------
-- Machine-local overrides — untracked, same tier as ~/.config/sh/local.sh.
-- WezTerm puts the config directory on package.path, so this just works.
-- ---------------------------------------------------------------------------
local ok, machine = pcall(require, "machine")
if ok and type(machine) == "table" then
  for k, v in pairs(machine) do
    config[k] = v
  end
end

return config
```

**`ssh_domains` lives in `machine.lua`, not here.** §8 puts internal hostnames in
the untracked tier, and an `ssh_domains` table is a list of internal hostnames.
The shape, for the record:

```lua
-- ~/.config/wezterm/machine.lua — untracked
return {
  ssh_domains = {
    { name = "build", remote_address = "buildbox.internal", username = "bsilver" },
  },
}
```

This also replaces the Windows Terminal profiles the old repo carried
(`config/windows-terminal/`, deleted in §9): a WSL entry in the launcher plus
`default_domain` is the same thing expressed once.

## 7.37 `home/dot_config/tmux/tmux.conf`

Rewritten for two reasons. First, the plugin path: the old file ends with
`run '~/.tmux/plugins/tpm/tpm'`, and nothing in this repo ever puts anything at
`~/.tmux/`, so on a fresh machine every `set -g @plugin` line is inert and the
theme file — loaded *after* tpm on purpose — is the only thing that renders.
Second, `bind s` is defined twice (a split and a popup); the popup wins silently,
which is why `s` never split a window.

```sh
# ============================================================================
# Core
# ============================================================================
set -g default-terminal "tmux-256color"

# terminal-features is the tmux 3.2+ form; the terminal-overrides pile in the
# old config predates it and listed ghostty and alacritty, both deleted in §9.
# One terminal now (§3), so one line — plus xterm-256color for the case where
# something upstream has already flattened TERM.
set -as terminal-features ",wezterm*:RGB:usstyle"
set -as terminal-features ",xterm-256color:RGB:usstyle"

set -g escape-time 0
set -g mouse on
set -g renumber-windows on
set -g repeat-time 1000
set -g base-index 1
set -g pane-base-index 1
set -g mode-keys vi
set -g status-position top
set -g detach-on-destroy off
set -g history-limit 1000000
set -g focus-events on
set -g set-titles on
set -g set-titles-string "#S / #W"
setw -g aggressive-resize on

# Replaces tmux-yank (§7.7). tmux emits OSC 52 and WezTerm honours it, so this
# copies to the *local* clipboard even from a pane on a remote host.
set -g set-clipboard on

# ============================================================================
# Theme
# ============================================================================
# themes/<name>.conf owns every visual setting; this file owns behaviour.
# theme.conf is generated from the `theme` variable (§7.35); point this at a
# different name to test a hand-written scheme without touching chezmoi.
set -g @theme "theme"
set -g status-left-length 100
set -g status-right-length 100
set -g status-interval 5

# ============================================================================
# Keys
# ============================================================================
unbind C-b
unbind %
unbind '"'
set -g prefix C-a
bind C-a send-prefix

# Splits. The old config bound four keys to two actions and lost one of them to
# a name collision; these two are the whole set.
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux: reloaded"
bind W command-prompt "rename-window %%"
bind R command-prompt "rename-session %%"
bind z resize-pane -Z
bind C-a last-window

# Pane navigation. M- rather than C-, because vim-tmux-navigator is gone
# (§7.7): C-h is backspace and C-l is clear-screen, and binding them
# prefixlessly without the plugin's foreground-process check breaks both in
# every shell. prefix-hjkl still works for the same moves.
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind \\ select-pane -l

bind -r H resize-pane -L
bind -r J resize-pane -D
bind -r K resize-pane -U
bind -r L resize-pane -R

# Windows
bind -n S-Left previous-window
bind -n S-Right next-window
bind -n M-1 select-window -t :1
bind -n M-2 select-window -t :2
bind -n M-3 select-window -t :3
bind -n M-4 select-window -t :4
bind -n M-5 select-window -t :5
bind -n M-6 select-window -t :6
bind -n M-7 select-window -t :7
bind -n M-8 select-window -t :8
bind -n M-9 select-window -t :9

# The old config also bound M-0 to window 0, which base-index 1 guarantees
# does not exist.

# Sessionizer. Was `tmux neww`, which leaves a dead window behind when fzf is
# cancelled; a popup does not.
bind f display-popup -E -w 80% -h 60% "~/.local/bin/tmux-sessionizer"

# The old config bound Z to ~/.local/bin/tmux-zoxide, a script that does not
# exist in the repo. Zoxide results are folded into the sessionizer instead
# (§7.48), so one binding covers both.

bind s display-popup -E -w 60% -h 40% "\
    tmux list-sessions -F '#{?session_attached,,#{session_name}}' \
    | sed '/^$/d' \
    | fzf --reverse --header jump-to-session \
    | xargs -r tmux switch-client -t"

bind S display-popup -E -w 60% -h 40% "\
    tmux list-windows -F '#{window_index} #{window_name}' \
    | sed '/^$/d' \
    | fzf --reverse --header jump-to-window \
    | cut -d ' ' -f 1 \
    | xargs -r tmux select-window -t"

# ============================================================================
# workmux (§7.25)
# ============================================================================
# Replaces tmux-claude-session-manager. Guarded with command -v so these are
# no-ops rather than error popups on a box where workmux is not installed.
bind -n M-w if-shell 'command -v workmux' 'display-popup -E -w 90% -h 90% "workmux dashboard"'
bind -n M-a if-shell 'command -v workmux' 'run-shell "workmux last-done"'
bind -n M-s if-shell 'command -v workmux' 'run-shell "workmux sidebar"'

# ============================================================================
# Copy mode
# ============================================================================
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi Escape send-keys -X cancel
bind-key -T copy-mode-vi H send-keys -X start-of-line
bind-key -T copy-mode-vi L send-keys -X end-of-line

# ============================================================================
# Plugins — fetched by .chezmoiexternal.toml (§7.7), sourced directly.
# No tpm, so no `prefix-I` step on a new machine and no runtime cloning.
# ============================================================================
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-dir "$HOME/.local/state/tmux/resurrect"
set -g @continuum-restore 'off'
set -g @continuum-save-interval '15'

# -b so a missing external cannot block tmux from finishing startup.
if-shell '[ -x ~/.config/tmux/plugins/tmux-resurrect/resurrect.tmux ]' \
    'run-shell -b ~/.config/tmux/plugins/tmux-resurrect/resurrect.tmux'
# continuum must load after resurrect — it drives it.
if-shell '[ -x ~/.config/tmux/plugins/tmux-continuum/continuum.tmux ]' \
    'run-shell -b ~/.config/tmux/plugins/tmux-continuum/continuum.tmux'

# ============================================================================
# Load theme last, so it can override anything a plugin styled.
# run-shell, not source-file: only run-shell format-expands #{@theme}.
# ============================================================================
run-shell 'tmux source-file ~/.config/tmux/themes/#{@theme}.conf 2>/dev/null \
  || tmux display-message "tmux: no theme named #{@theme}"'
```

`@resurrect-dir` is new: resurrect defaults to `~/.tmux/resurrect`, the same
`~/.tmux` this design otherwise eliminates. Pointing it at XDG state keeps the
home directory clean and puts saved sessions somewhere obviously disposable.

## 7.38 `home/dot_config/tmux/themes/theme.conf.tmpl`

Renamed from `onedark.conf`, because there is only ever one of these now — the
scheme is chosen at the chezmoi layer (§7.35), not by which of several `.conf`
files `@theme` points at. `tmux.conf` keeps its indirection (`set -g @theme
"theme"`) so a hand-written scratch theme can still be dropped in beside this
one, but the tracked path is a single generated file.

The structure is unchanged from the old file, including the one real trap it
documents: colour-type options are parsed at set time and never
format-expanded, so `display-panes-colour` and `clock-mode-colour` cannot use
`#{@od_*}` and must be literal — which under templating means rendering the hex
directly rather than via a tmux user option.

```sh
{{- $t := index .themes (.theme | default "onedark") -}}
{{- $p := $t.palette -}}
# ============================================================================
# {{ $t.name }} — generated from .chezmoidata/themes.yaml (§7.35)
# Do not hand-edit: `chezmoi apply` overwrites this file.
# ============================================================================
set -g @od_bg      "{{ $p.bg }}"
set -g @od_bg_alt  "{{ $p.bg_alt }}"
set -g @od_surface "{{ $p.surface }}"
set -g @od_fg      "{{ $p.fg }}"
set -g @od_grey    "{{ $p.grey }}"
set -g @od_red     "{{ $p.red }}"
set -g @od_green   "{{ $p.green }}"
set -g @od_yellow  "{{ $p.yellow }}"
set -g @od_orange  "{{ $p.orange }}"
set -g @od_blue    "{{ $p.blue }}"
set -g @od_magenta "{{ $p.magenta }}"
set -g @od_cyan    "{{ $p.cyan }}"

# Status bar
set -g status-style "fg=#{@od_fg},bg=#{@od_bg_alt}"
set -g status-left ""
set -g window-status-separator ""
set -g window-status-format "#[fg=#{@od_grey},bg=#{@od_bg_alt}] #I #W#{?window_zoomed_flag, [Z],} "
set -g window-status-current-format "#[fg=#{@od_bg},bg=#{@od_blue},bold] #I #W#{?window_zoomed_flag, [Z],} "
set -g window-status-activity-style "fg=#{@od_yellow},bg=#{@od_bg_alt}"
set -g window-status-bell-style "fg=#{@od_red},bg=#{@od_bg_alt},bold"

# session │ host │ date time
set -g status-right "#[fg=#{@od_magenta}]#{?client_prefix,#[reverse],} #S #[none]"
set -ag status-right "#[fg=#{@od_grey}]│#[fg=#{@od_green}] #h "
set -agF status-right "#[fg=#{@od_grey}]│#[fg=#{@od_blue}] %Y-%m-%d %H:%M "

# Panes
set -g pane-border-style "fg=#{@od_surface}"
set -g pane-active-border-style "fg=#{@od_blue}"

# colour-type options are parsed at set time and never format-expanded, so
# #{@od_*} would be silently dropped here — rendered literal instead.
set -g display-panes-colour "{{ $p.grey }}"
set -g display-panes-active-colour "{{ $p.blue }}"

# Messages, copy mode, clock
set -g message-style "fg=#{@od_bg},bg=#{@od_yellow},bold"
set -g message-command-style "fg=#{@od_bg},bg=#{@od_orange},bold"
set -g mode-style "fg=#{@od_bg},bg=#{@od_blue}"
set -g copy-mode-match-style "fg=#{@od_bg},bg=#{@od_yellow}"
set -g copy-mode-current-match-style "fg=#{@od_bg},bg=#{@od_orange}"
set -g clock-mode-colour "{{ $p.blue }}"
```

The `@od_` prefix is now a misnomer for three of the four schemes. It stays
because renaming it to `@th_` touches thirty lines to no effect, and because
"od" reads as "the theme's" in context. Rename it if it ever grates.

## 7.39 `home/dot_config/lazygit/config.yml.tmpl`

The old file is 96 lines, of which 60 are three commented-out themes for
colourschemes this repo does not use, and the remaining 36 are the fourth theme.
There is no editor setting, no pager, no keybinding, nothing. Lazygit is bound
to `gg` in `20-aliases.sh` and to `<leader>gg` in both Zed and VS Code, so it is
a primary interface, not a side tool.

The three commented-out theme blocks in the old file were rose-pine, catppuccin,
and dracula — the exact set §7.35 now makes selectable. They are not deleted so
much as promoted: the palettes moved into `themes.yaml` and this file renders
whichever one is active.

```yaml
{{- $t := index .themes (.theme | default "onedark") -}}
{{- $p := $t.palette -}}
gui:
  nerdFontsVersion: "3"
  showFileIcons: true
  border: rounded
  showRandomTip: false
  showCommandLog: false
  showDivergenceFromBaseBranch: arrowAndNumber
  filterMode: fuzzy
  sidePanelWidth: 0.28
  mainPanelSplitMode: flexible
  timeFormat: "2006-01-02"
  shortTimeFormat: "15:04"
  theme:
    activeBorderColor: ["{{ $p.blue }}", bold]
    inactiveBorderColor: ["{{ $p.grey }}"]
    searchingActiveBorderColor: ["{{ $p.cyan }}", bold]
    optionsTextColor: ["{{ $p.green }}"]
    selectedLineBgColor: ["{{ $p.surface }}"]
    inactiveViewSelectedLineBgColor: ["{{ $p.bg_alt }}"]
    cherryPickedCommitFgColor: ["{{ $p.bg }}"]
    cherryPickedCommitBgColor: ["{{ $p.yellow }}"]
    markedBaseCommitFgColor: ["{{ $p.bg }}"]
    markedBaseCommitBgColor: ["{{ $p.yellow }}"]
    unstagedChangesColor: ["{{ $p.red }}"]
    defaultFgColor: ["{{ $p.fg }}"]
  authorColors:
    "*": "{{ $p.magenta }}"

git:
  paging:
    colorArg: always
    # Same pager as `git diff` (§7.22), so a hunk looks identical in both.
    # --syntax-theme is passed explicitly rather than inherited from
    # ~/.gitconfig: lazygit invokes delta directly, not through git.
    pager: delta {{ if $t.dark }}--dark{{ else }}--light{{ end }} --paging=never --line-numbers --syntax-theme={{ $t.bat.theme | quote }}
  commit:
    signOff: false
    autoWrapCommitMessage: true
    autoWrapWidth: 72
  # Unset would auto-detect per repo; naming both is what makes
  # showDivergenceFromBaseBranch above useful on the repos still on master.
  mainBranches: [main, master]
  autoFetch: true
  autoRefresh: true
  fetchAll: false
  parseEmoji: false
  log:
    order: topo-order
    showGraph: always

os:
  # Drives `e`, `o`, and the "open at line" actions in one setting.
  editPreset: nvim

# lazygit suspends itself to run the editor; returning straight to the UI is
# the whole point of editing from inside it.
promptToReturnFromSubprocess: false
disableStartupPopups: true
confirmOnQuit: false

update:
  method: never

customCommands:
  # `w` is unbound in the branches context. Hands the branch to workmux, which
  # creates the worktree and the tmux window in one step (§7.25).
  - key: "w"
    context: "localBranches"
    description: "workmux: open branch in a worktree + window"
    command: "workmux add {{.SelectedLocalBranch.Name}}"
    subprocess: true
```

**Windows.** This is the tool §5 flagged as an unverified XDG bet. It is settled
rather than deferred: `LG_CONFIG_FILE` is an absolute override that outranks
every discovery rule, and both `10-env.sh` (§7.14) and the PowerShell profile
(§7.26) now set it. The step-3 check becomes `lazygit --print-config-dir`
returning the `~/.config` path, not an investigation.

**Not set, on purpose.** `os.copyToClipboardCmd` — on WSL the correct value is
`clip.exe`, everywhere else the default is right. That is one conditional line,
and turning this file into a template for it would trip §12's over-templating
rule. If clipboard-from-lazygit-on-WSL turns out to matter, it belongs in the
machine-local tier, not here.

## 7.40 `home/dot_config/starship.toml.tmpl`

The old file is 130 lines and configures no modules at all: it defines five
palettes, selects one, and stops. Everything on screen is starship's default
prompt in slightly different colours. Four of the five palettes are for
colourschemes nothing else in the repo uses; they go.

The five palettes in the old file collapse to one rendered palette. The module
bodies below reference semantic names (`blue`, `purple`, `mono3`), so they are
identical for all four schemes — only the `[palettes.theme]` block changes.

```toml
{{- $t := index .themes (.theme | default "onedark") -}}
{{- $p := $t.palette -}}
"$schema" = 'https://starship.rs/config-schema.json'

format = """
$directory$git_branch$git_state$git_status$cmd_duration
$character"""

right_format = "$c$rust$golang$java$python$nodejs$docker_context$time"

add_newline = true
command_timeout = 1000
palette = "theme"

# Generated from .chezmoidata/themes.yaml (§7.35).
[palettes.theme]
mono0 = '{{ $p.fg_bright }}'
mono1 = '{{ $p.fg }}'
mono3 = '{{ $p.grey }}'
mono4 = '{{ $p.black }}'
red = '{{ $p.red }}'
green = '{{ $p.green }}'
yellow = '{{ $p.yellow }}'
blue = '{{ $p.blue }}'
purple = '{{ $p.magenta }}'
cyan = '{{ $p.cyan }}'
orange = '{{ $p.orange }}'

[directory]
style = "blue bold"
truncation_length = 3
truncate_to_repo = true
truncation_symbol = "…/"
read_only = " "

[git_branch]
symbol = " "
style = "purple"
format = "[$symbol$branch]($style) "

[git_status]
style = "red"
format = '([$all_status$ahead_behind]($style) )'
conflicted = "="
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "\\$${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"

[git_state]
style = "yellow bold"
format = '\([$state( $progress_current/$progress_total)]($style)\) '

[cmd_duration]
min_time = 2000
style = "yellow"
format = "[ $duration]($style) "

[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"
vimcmd_symbol = "[❮](orange)"

[time]
disabled = false
style = "mono3"
format = "[$time]($style)"
time_format = "%H:%M"

# Right-prompt language modules: version only when the project actually uses
# the language. symbol + version, no prose.
[c]
symbol = " "
style = "blue"
format = "[$symbol($version )]($style)"
[rust]
symbol = " "
style = "orange"
format = "[$symbol($version )]($style)"
[golang]
symbol = " "
style = "cyan"
format = "[$symbol($version )]($style)"
[java]
symbol = " "
style = "red"
format = "[$symbol($version )]($style)"
[python]
symbol = " "
style = "yellow"
format = "[$symbol($version )]($style)"
[nodejs]
symbol = " "
style = "green"
format = "[$symbol($version )]($style)"
[docker_context]
symbol = " "
style = "blue"
format = "[$symbol$context]($style) "
only_with_files = true

# ---------------------------------------------------------------------------
# Disabled — see note below.
# ---------------------------------------------------------------------------
[aws]
disabled = true
[gcloud]
disabled = true
[azure]
disabled = true
[kubernetes]
disabled = true
[hostname]
ssh_only = true
style = "green"
format = "[$hostname]($style) "
```

**Why `[aws] disabled = true` is a secrets decision, not a taste one.** §7.34
puts `AWS_PROFILE` and `AWS_REGION` in the untracked `local.sh` on work
machines precisely so an account identifier never lands in a tracked file.
Starship's `aws` module reads exactly those variables and renders them into the
prompt — which is in every screen share, every terminal screenshot, and every
asciinema recording. Same reasoning for `gcloud`, `azure`, and `kubernetes`.
This is the one module setting in the file that should not be changed casually.

`[hostname] ssh_only = true` earns its place for the opposite reason: on the
headless work box (§4) it is the only thing distinguishing that prompt from a
local one.

## 7.41 `home/dot_config/bat/config.tmpl`

The old directory is a one-line config plus four Catppuccin `.tmTheme` files
totalling ~400 KB. The config selects `OneHalfDark`, a *built-in* theme, and
nothing anywhere runs `bat cache --build`, without which a custom `.tmTheme` in
`themes/` is not registered at all. So the four files were inert — and, being
Catppuccin, they were also evidence of exactly the theme-switching itch §7.35
now scratches properly.

bat is the awkward one of the name-driven tools. Two of the four schemes are
built in (`OneHalfDark`, `Dracula`) and two are not, so `themes.yaml` carries an
optional `bat.tmtheme` git URL and two things key off its presence:

**`.chezmoiexternal.toml` becomes `.chezmoiexternal.toml.tmpl`** and grows a
conditional entry:

```
{{- $t := index .themes (.theme | default "onedark") -}}
{{- if $t.bat.tmtheme }}
[".config/bat/themes"]
    type = "git-repo"
    url = {{ $t.bat.tmtheme | quote }}
    refreshPeriod = "168h"
{{- end }}
```

**A new `run_onchange_after_23-bat-cache.sh.tmpl`** rebuilds the cache, and only
when there is something to build:

```
{{- if (index .themes (.theme | default "onedark")).bat.tmtheme -}}
#!/bin/sh
set -eu
# theme: {{ .theme }}
command -v bat >/dev/null 2>&1 || exit 0
bat cache --build >/dev/null
{{- end }}
```

The `# theme: {{ .theme }}` line is load-bearing: `run_onchange_` hashes the
rendered script, so without it the file is byte-identical across two schemes
that both need a `.tmtheme` and the cache never rebuilds on the switch between
them.

```
{{- $t := index .themes (.theme | default "onedark") -}}
--theme={{ $t.bat.theme | quote }}
--style="numbers,changes,header-filename"
--italic-text=always

# fzf's preview (§7.16) and delta both call bat; paging from inside them would
# deadlock. Interactive paging comes from $PAGER (§7.14) instead.
--paging=never

# Extensionless files bat otherwise renders as plain text.
--map-syntax=".chezmoiignore:Git Ignore"
--map-syntax=".chezmoiexternal.toml:TOML"
--map-syntax="*.tmpl:Jinja2"
--map-syntax=".gitconfig.local:INI"
--map-syntax="**/.ssh/conf.d/*.conf:SSH Config"
```

`--theme` names a bat theme, and `[delta] syntax-theme` in §7.22 names the same
one, so a diff hunk and a `bat` page of the same file colour identically. §7.22
renders it from the same field:

```
[delta]
    syntax-theme = {{ (index .themes (.theme | default "onedark")).bat.theme }}
    {{ if (index .themes (.theme | default "onedark")).dark }}dark{{ else }}light{{ end }} = true
```

delta uses bat's theme registry, which is why one field drives both — and why
delta gets the custom `.tmtheme` for free once `bat cache --build` has run.

## 7.42 `home/dot_config/git/ignore`

Git reads `$XDG_CONFIG_HOME/git/ignore` as the global excludes file with no
configuration at all, so this needs no `core.excludesFile` line in §7.22. The
old repo had `git/gitignore` sitting in the tree with nothing pointing at it —
it was never wired up.

```gitignore
# OS
.DS_Store
Thumbs.db
desktop.ini

# Editors and tools
.idea/
.vscode/
*.swp
*.swo

# Per-project environments — machine-specific, never committed anywhere
.envrc
.direnv/
.env.local

# Worktree and agent scratch. workmux (§7.25) puts worktrees outside the repo,
# but per-repo .workmux.yaml overrides may not.
.workmux.local.yaml
.claude/settings.local.json
```

`.claude/settings.local.json` is here rather than in each repo because it is the
*project*-level Claude Code override — the file §7.34 is still trying to confirm
has a user-level equivalent. Either way it is per-machine and must not be
committed to anyone's project.

## 7.43 VS Code: `home/.chezmoitemplates/vscode/settings.json` + three shims

### The path problem

§6 originally put this at `home/dot_config/Code/User/`. That is the correct
path on **Linux only**:

| Platform | VS Code user-settings directory |
|---|---|
| Linux | `~/.config/Code/User/` |
| macOS | `~/Library/Application Support/Code/User/` |
| Windows | `%APPDATA%\Code\User\` → `~/AppData/Roaming/Code/User/` |

VS Code does not honour `XDG_CONFIG_HOME` on macOS or Windows, and unlike
lazygit it exposes no override environment variable. So the §5 "force XDG
everywhere" strategy has exactly one hard exception beyond the PowerShell
profile, and this is it. Left as-is, the macOS and Windows desktops would have
had a `~/.config/Code/User/settings.json` that VS Code never reads.

### The fix: one body, three targets

chezmoi's `.chezmoitemplates/` holds content that is not itself a target file.
Three one-line target files include it, and §7.6 excludes the two that do not
apply to the current platform.

```
home/.chezmoitemplates/vscode/settings.json          <- the real content
home/.chezmoitemplates/vscode/keybindings.json       <- the real content

home/dot_config/Code/User/settings.json.tmpl
home/Library/Application Support/Code/User/settings.json.tmpl
home/AppData/Roaming/Code/User/settings.json.tmpl
```

Each shim is exactly one line:

```
{{ template "vscode/settings.json" . }}
```

Source directory names may contain spaces, so `Library/Application Support/`
needs no escaping or attribute prefix.

**WSL caveat.** On the WSL target, VS Code runs as a Remote-WSL *server*: user
settings come from the Windows-side client, and the Linux side reads only
`~/.vscode-server/data/Machine/settings.json`. Writing `~/.config/Code/User/`
inside WSL is harmless but misleading, so §7.6 excludes it there too. Add `$wsl`
to that file's header:

```
{{- $wsl := and (eq .chezmoi.os "linux") (contains "microsoft" (lower .chezmoi.kernel.osrelease)) -}}
```

and gate the Linux branch on `(and (eq .chezmoi.os "linux") (not $wsl))`.

### The content

Carried from `config/vscode/settings.json`, which was already good — the vim
keymap block is the parity layer that makes Neovim, IdeaVim, Zed, and VS Code
agree on `<leader>` mappings, and it is reproduced verbatim. What is new is
everything the old file left to VS Code's defaults or to Settings Sync: theme,
font, terminal profiles.

Because the shim files are already templates, the body gets the §7.35 header
too and the `.chezmoitemplates` copy is itself templated — `template` renders
its body in the caller's context, so `.themes` and `.theme` are both in scope.

```jsonc
{{- $t := index .themes (.theme | default "onedark") -}}
{
    // --- appearance -------------------------------------------------------
    // The theme extension is installed by §7.32 from the same themes.yaml row
    // that supplies this name; naming a theme whose extension is absent leaves
    // VS Code on its default with no error.
    "workbench.colorTheme": {{ $t.vscode.name | quote }},
    "workbench.iconTheme": "material-icon-theme",
    "workbench.productIconTheme": "material-product-icons",
    "editor.fontFamily": "'JetBrainsMono Nerd Font', 'Symbols Nerd Font Mono', monospace",
    "editor.fontSize": 13,
    "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",

    // file settings
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,

    // editor appearance and behavior
    "editor.cursorBlinking": "smooth",
    "editor.cursorSmoothCaretAnimation": "on",
    "editor.fontLigatures": true,
    "editor.lineNumbers": "relative",
    "editor.minimap.enabled": false,
    "editor.smoothScrolling": true,
    "editor.renderWhitespace": "boundary",
    // Matches Zed's "format_on_save": "off" (§7.45). Formatting is a
    // deliberate act (<leader>cf) in every editor here, not a save side effect.
    "editor.formatOnSave": false,

    // terminal configuration
    "terminal.integrated.scrollback": 10000,
    "terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)",
    "terminal.integrated.defaultProfile.linux": "zsh",
    "terminal.integrated.defaultProfile.osx": "zsh",

    // file explorer settings
    "explorer.compactFolders": true,
    "explorer.confirmDragAndDrop": false,

    // search
    "search.smartCase": true,
    "search.seedWithNearestWord": true,

    // workbench settings
    "workbench.activityBar.location": "default",
    "workbench.editor.enablePreview": false,
    "workbench.settings.editor": "json",
    "workbench.experimental.modernUI": false,
    "window.menuBarVisibility": "compact",
    "window.commandCenter": false,

    // git settings
    "git.autofetch": true,
    "git.autorefresh": true,
    "git.confirmSync": false,
    "git.mergeEditor": true,
    "git.suggestSmartCommit": false,
    "git.openAfterClone": "always",
    "git.blame.editorDecoration.enabled": true,

    // diff and scm settings
    "diffEditor.ignoreTrimWhitespace": false,
    "diffEditor.hideUnchangedRegions.enabled": true,
    "diffEditor.renderSideBySide": true,
    "scm.defaultViewMode": "list",

    // misc settings
    "telemetry.telemetryLevel": "off",
    "redhat.telemetry.enabled": false,
    "update.showReleaseNotes": false,

    // vim
    "vim.foldfix": true,
    "vim.leader": "<space>",
    "vim.smartRelativeLine": true,
    "vim.useSystemClipboard": true,
    "vim.handleKeys": {
        "<C-p>": false,
        "<C-b>": false,
        "<C-f>": false
    },
    "vim.normalModeKeyBindingsNonRecursive": [
        { "before": ["<Esc>"], "commands": [":nohlsearch"], "when": "editorTextFocus", "silent": true },

        // split / pane navigation without the <c-w> prefix
        { "before": ["<c-h>"], "commands": ["workbench.action.navigateLeft"] },
        { "before": ["<c-j>"], "commands": ["workbench.action.navigateDown"] },
        { "before": ["<c-k>"], "commands": ["workbench.action.navigateUp"] },
        { "before": ["<c-l>"], "commands": ["workbench.action.navigateRight"] },

        // buffer (tab) navigation
        { "before": ["[", "b"], "commands": ["workbench.action.previousEditorInGroup"] },
        { "before": ["]", "b"], "commands": ["workbench.action.nextEditorInGroup"] },
        { "before": ["[", "B"], "commands": ["workbench.action.firstEditorInGroup"] },
        { "before": ["]", "B"], "commands": ["workbench.action.lastEditorInGroup"] },

        // diagnostics
        { "before": ["[", "d"], "commands": ["editor.action.marker.prev"] },
        { "before": ["]", "d"], "commands": ["editor.action.marker.next"] },

        // git hunks
        { "before": ["[", "c"], "commands": ["workbench.action.editor.previousChange"] },
        { "before": ["]", "c"], "commands": ["workbench.action.editor.nextChange"] },

        // lsp — neovim 0.11+ builtin defaults
        { "before": ["g", "r", "n"], "commands": ["editor.action.rename"] },
        { "before": ["g", "r", "a"], "commands": ["editor.action.quickFix"] },
        { "before": ["g", "r", "r"], "commands": ["references-view.findReferences"] },
        { "before": ["g", "r", "i"], "commands": ["references-view.findImplementations"] },
        { "before": ["g", "r", "t"], "commands": ["editor.action.goToTypeDefinition"] },
        { "before": ["g", "O"], "commands": ["workbench.action.gotoSymbol"] },
        { "before": ["g", "d"], "commands": ["editor.action.revealDefinition"] },
        { "before": ["g", "D"], "commands": ["editor.action.revealDeclaration"] },
        { "before": ["K"], "commands": ["editor.action.showHover"] },
        { "before": ["<c-w>", "d"], "commands": ["editor.action.showHover"] },
        { "before": ["g", "r", "c"], "commands": ["references-view.showCallHierarchy"] },
        { "before": ["g", "r", "s"], "commands": ["workbench.action.showAllSymbols"] },

        // searching
        { "before": ["<leader>", "<space>"], "commands": ["workbench.action.quickOpen"] },
        { "before": ["<leader>", "/"], "commands": ["workbench.action.quickTextSearch"] },
        { "before": ["<leader>", ","], "commands": ["workbench.action.showAllEditors"] },
        { "before": ["<leader>", ":"], "commands": ["workbench.action.showCommands"] },
        { "before": ["<leader>", "s", "s"], "commands": ["workbench.action.gotoSymbol"] },
        { "before": ["<leader>", "s", "S"], "commands": ["workbench.action.showAllSymbols"] },
        { "before": ["<leader>", "s", "w"], "commands": ["workbench.action.findInFiles"] },

        // buffer
        { "before": ["<leader>", "b", "d"], "commands": ["workbench.action.closeActiveEditor"] },

        // diagnostics list
        { "before": ["<leader>", "x", "x"], "commands": ["workbench.actions.view.problems"] },

        // splits
        { "before": ["<leader>", "-"], "commands": ["workbench.action.splitEditorDown"] },
        { "before": ["<leader>", "|"], "commands": ["workbench.action.splitEditorRight"] },

        // git — parity with Zed's <leader>g prefix (§7.46). gg opens lazygit
        // in the integrated terminal rather than the SCM view, which is what
        // the same key does in Zed and in tmux.
        { "before": ["<leader>", "g", "g"], "commands": ["workbench.action.terminal.new"] },
        { "before": ["<leader>", "g", "b"], "commands": ["gitlens.toggleFileBlame"] },
        { "before": ["<leader>", "g", "d"], "commands": ["git.openChange"] },

        // panels — parity with Zed
        { "before": ["<leader>", "e"], "commands": ["workbench.view.explorer"] },
        { "before": ["<leader>", "t"], "commands": ["workbench.action.terminal.toggleTerminal"] },
        { "before": ["<leader>", "a"], "commands": ["claude-code.focus"] },
        { "before": ["<leader>", "c", "f"], "commands": ["editor.action.formatDocument"] },
        { "before": ["<leader>", "c", "a"], "commands": ["editor.action.quickFix"] },
        { "before": ["<leader>", "c", "r"], "commands": ["editor.action.rename"] }
    ],
    "vim.visualModeKeyBindingsNonRecursive": [
        { "before": ["g", "r", "a"], "commands": ["editor.action.quickFix"] },
        { "before": ["<c-h>"], "commands": ["workbench.action.navigateLeft"] },
        { "before": ["<c-j>"], "commands": ["workbench.action.navigateDown"] },
        { "before": ["<c-k>"], "commands": ["workbench.action.navigateUp"] },
        { "before": ["<c-l>"], "commands": ["workbench.action.navigateRight"] },
        { "before": ["<"], "commands": ["editor.action.outdentLines"] },
        { "before": [">"], "commands": ["editor.action.indentLines"] }
    ],
    "vim.insertModeKeyBindingsNonRecursive": [
        { "before": ["<c-s>"], "commands": ["editor.action.triggerParameterHints"] }
    ],

    // plugins
    "remote.extensionKind": {
        "alefragnani.project-manager": ["workspace"]
    },
    "projectManager.git.baseFolders": [
        "$home/dev/projects",
        "$home/Developer/projects"
    ],

    // languages
    "yaml.disableSchemaDetection": [
        "**/.github/workflows/*.yml",
        "**/.github/workflows/*.yaml",
        "**/.gitea/workflows/*.yml",
        "**/.gitea/workflows/*.yaml",
        "**/.forgejo/workflows/*.yml",
        "**/.forgejo/workflows/*.yaml"
    ],
    "claudeCode.useTerminal": true,
    "github.copilot.enable": {
        "*": false,
        "plaintext": false,
        "markdown": false,
        "scminput": false
    }
}
```

Two fixes carried in silently above: the old file ended with a trailing comma
after the last property (legal in VS Code's JSONC, illegal if anything else ever
parses it), and `"vim.normalModeKeyBindingsNonRecursive"` had no `<leader>g`
entries at all despite Zed and IdeaVim both defining them.

The `<leader>gg` mapping is the one imperfect member of the parity set: VS Code
cannot spawn a named terminal task the way Zed's `task::Spawn` does, so it opens
a terminal and lazygit is one `gg` away (`20-aliases.sh`).

## 7.44 `home/.chezmoitemplates/vscode/keybindings.json`

Carried over as-is. It does two jobs: vim-style single-key file operations in
the explorer, and `ctrl+hjkl` escape from the terminal and sidebar — the
counterpart to the in-editor bindings in §7.43, which vim handles instead.

```jsonc
[
    // vim-style file operations in the explorer tree
    { "key": "a", "command": "workbench.files.action.createFileFromExplorer",
      "when": "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus" },
    { "key": "c", "command": "filesExplorer.copy",
      "when": "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus" },
    { "key": "x", "command": "filesExplorer.cut",
      "when": "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus" },
    { "key": "p", "command": "filesExplorer.paste",
      "when": "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus" },
    { "key": "d", "command": "deleteFile",
      "when": "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus" },
    { "key": "r", "command": "renameFile",
      "when": "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus" },
    { "key": "enter", "command": "list.select",
      "when": "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus" },
    { "key": "enter", "command": "-renameFile",
      "when": "filesExplorerFocus && foldersViewVisible && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus" },

    // pane navigation out of the terminal (vim handles the editor side)
    { "key": "ctrl+h", "command": "workbench.action.navigateLeft",  "when": "terminalFocus" },
    { "key": "ctrl+j", "command": "workbench.action.navigateDown",  "when": "terminalFocus" },
    { "key": "ctrl+k", "command": "workbench.action.navigateUp",    "when": "terminalFocus" },
    { "key": "ctrl+l", "command": "workbench.action.navigateRight", "when": "terminalFocus" },

    // pane navigation out of the sidebar / explorer tree
    { "key": "ctrl+h", "command": "workbench.action.navigateLeft",  "when": "sideBarFocus && !inputFocus" },
    { "key": "ctrl+j", "command": "workbench.action.navigateDown",  "when": "sideBarFocus && !inputFocus" },
    { "key": "ctrl+k", "command": "workbench.action.navigateUp",    "when": "sideBarFocus && !inputFocus" },
    { "key": "ctrl+l", "command": "workbench.action.navigateRight", "when": "sideBarFocus && !inputFocus" },

    { "key": "escape", "command": "closeMarkersNavigation",
      "when": "editorFocus && markersNavigationVisible" }
]
```

## 7.45 `home/dot_config/zed/settings.json.tmpl`

Zed is XDG-native on both macOS and Linux — `~/.config/zed/` on each — so it
needs none of §7.43's machinery. Windows support is still preview and uses
`%LOCALAPPDATA%\Zed`; §7.6 excludes Zed there rather than guessing.

**The source directory is an allowlist, exactly like `~/.claude` (§7.34).** The
live `config/zed/` in the old repo also contains `prompts/prompts-library-db.0.mdb`
(an LMDB database), `conversations/`, and `themes/`. Those are runtime state.
Three files are tracked and nothing else; **no `exact_` prefix**, for the same
reason as §7.34 — it would delete the prompt library on every apply.

Zed is the one name-driven tool that can install its own theme:
`auto_install_extensions` is a settings key, so chezmoi does not need a separate
install step the way VS Code does (§7.32). The `onedark` row has an empty
`extension` field because One Dark ships with Zed, hence the `if`.

```json
{{- $t := index .themes (.theme | default "onedark") -}}
{
  "theme": {
    "mode": "dark",
    "dark": {{ $t.zed.dark | quote }},
    "light": {{ $t.zed.light | quote }}
  },
{{- if $t.zed.extension }}
  "auto_install_extensions": {
    {{ $t.zed.extension | quote }}: true
  },
{{- end }}
  "icon_theme": {
    "mode": "dark",
    "light": "Zed (Default)",
    "dark": "Zed (Default)"
  },
  "buffer_font_family": "JetBrainsMono Nerd Font",
  "buffer_font_size": 13,
  "terminal": {
    "font_family": "JetBrainsMono Nerd Font",
    "shell": "system",
    "copy_on_select": false
  },

  "vim_mode": true,
  "vim": {
    "use_system_clipboard": "always",
    "use_smartcase_find": true,
    "toggle_relative_line_numbers": true
  },
  "relative_line_numbers": true,

  "colorize_brackets": true,
  "format_on_save": "off",
  "indent_guides": {
    "coloring": "indent_aware"
  },
  "remove_trailing_whitespace_on_save": true,
  "ensure_final_newline_on_save": true,

  "title_bar": {
    "show_onboarding_banner": false,
    "show_sign_in": false
  },
  "project_panel": { "dock": "left" },
  "outline_panel": { "dock": "left" },
  "collaboration_panel": { "dock": "left", "button": false },
  "git_panel": { "dock": "left", "tree_view": true },
  "agent": {
    "sidebar_side": "right",
    "dock": "right",
    "favorite_models": [],
    "model_parameters": []
  },
  "agent_servers": {
    "claude-acp": { "type": "registry" }
  },

  "git": {
    "worktree_directory": ".."
  },

  "telemetry": {
    "diagnostics": false,
    "metrics": false,
    "anthropic_retention": false
  }
}
```

Changed from the old file: theme `GitHub Dark` → whatever §7.35 selects, which
was the one config in the repo disagreeing with every other about colour; fonts
named explicitly rather than inherited; `relative_line_numbers` promoted out of
the `vim` block so it also applies outside vim mode; trailing-whitespace and
final-newline on save, matching §7.43.

Left alone: `"git": { "worktree_directory": ".." }` puts Zed's own worktrees
beside the repo while workmux (§7.25) puts its own under
`~/.local/state/workmux/`. That is a real inconsistency, but they are two
independent worktree creators and unifying them means making one of the tools
lie about where it put things. Pick workmux for anything that needs a tmux
window; Zed's is for a quick throwaway.

## 7.46 `home/dot_config/zed/keymap.json`

Carried over verbatim — it is the most complete member of the parity set and
the reference the other three editors were matched against. Reproduced here so
§7 stays copy-pasteable.

```jsonc
[
  {
    "context": "VimControl && !menu",
    "bindings": {
      "space space": "file_finder::Toggle",
      "space ,": "tab_switcher::Toggle",
      "space /": "pane::DeploySearch",
      "space :": "command_palette::Toggle",
      "space .": "outline::Toggle",
      "space f r": ["projects::OpenRecent", { "create_new_window": false }],
      "space f n": "workspace::NewFile",

      "space w": "workspace::Save",
      "space q": "pane::CloseActiveItem",
      "space b d": "pane::CloseActiveItem",
      "space b o": ["pane::CloseOtherItems", { "close_pinned": false }],

      "space -": "pane::SplitDown",
      "space |": "pane::SplitRight",

      "space c f": "editor::Format",
      "space c a": "editor::ToggleCodeActions",
      "space c r": "editor::Rename",
      "space c s": "outline_panel::Toggle",

      "space x x": "diagnostics::Deploy",

      "space d s": "debugger::Start",
      "space d b": "editor::ToggleBreakpoint",
      "space d B": "debugger::ToggleDataBreakpoint",
      "space d c": "debugger::Continue",
      "space d n": "debugger::StepOver",
      "space d i": "debugger::StepInto",
      "space d o": "debugger::StepOut",
      "space d r": "debugger::Restart",
      "space d t": "debugger::Stop",
      "space d u": "debug_panel::ToggleFocus",
      "space d e": "debugger::EvaluateSelectedText",

      "space g g": ["task::Spawn", { "task_name": "LazyGit", "reveal_target": "center" }],
      "space g b": "git::Blame",
      "space g d": "git::Diff",
      "space g p": "editor::ToggleSelectedDiffHunks",
      "space g h": "git_graph::Open",
      "space g w": "git::Worktree",

      "space h s": "git::StageAndNext",
      "space h r": "git::Restore",
      "space h S": "git::StageFile",
      "space h R": "git::RestoreFile",
      "space h d": "editor::ToggleSelectedDiffHunks",
      "space h p": "git::ToggleStaged",
      "space u b": "editor::ToggleGitBlameInline",

      "space e": "project_panel::ToggleFocus",
      "space t": "terminal_panel::Toggle",
      "space a": "agent::Toggle",

      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight"
    }
  },
  {
    "context": "ProjectPanel && not_editing",
    "bindings": {
      "escape": "project_panel::ToggleFocus",
      "space e": "project_panel::Toggle",
      "a": "project_panel::NewFile",
      "A": "project_panel::NewDirectory",
      "r": "project_panel::Rename",
      "d": "project_panel::Delete"
    }
  },
  {
    "context": "OutlinePanel",
    "bindings": { "escape escape": "outline_panel::Toggle" }
  },
  {
    "context": "AgentPanel && vim_mode == normal",
    "bindings": { "space a": "agent::Toggle" }
  },
  {
    "context": "GitPanel && not_editing",
    "bindings": { "space g g": "git_panel::Toggle" }
  },
  {
    "context": "ProjectPanel || AgentPanel || GitPanel || OutlinePanel",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight"
    }
  },
  {
    "context": "Terminal",
    "bindings": { "escape escape": "workspace::ToggleBottomDock" }
  },
  {
    "context": "ProjectSearchView",
    "bindings": { "escape": "workspace::ToggleBottomDock" }
  }
]
```

## 7.47 `home/dot_config/zed/tasks.json`

The old file had three tasks, two of which (`gh enhance`, `gh dash`) shell out
to `gh` extensions that no install step in this repo ever installs — so they
were two silent failures waiting for a keypress. `gh dash` earns its place, so
it becomes a real dependency; `gh enhance` is not a published extension and goes.

```json
[
  {
    "label": "LazyGit",
    "command": "lazygit",
    "shell": { "program": "sh" },
    "hide": "on_success",
    "reveal_target": "center",
    "show_summary": false,
    "show_command": false,
    "allow_concurrent_runs": true,
    "use_new_terminal": true
  },
  {
    "label": "Workmux Dashboard",
    "command": "workmux dashboard",
    "shell": { "program": "sh" },
    "hide": "on_success",
    "reveal_target": "center",
    "show_summary": false,
    "show_command": false,
    "allow_concurrent_runs": false,
    "use_new_terminal": true
  },
  {
    "label": "Dash",
    "command": "gh dash",
    "shell": { "program": "sh" },
    "hide": "on_success",
    "reveal_target": "center",
    "show_summary": false,
    "show_command": false,
    "allow_concurrent_runs": true,
    "use_new_terminal": true
  }
]
```

`gh dash` is a `gh` extension, not a package. It needs one line in §7.30's Unix
branch:

```sh
gh extension list 2>/dev/null | grep -q dlvhdr/gh-dash || gh extension install dlvhdr/gh-dash
```

This runs unauthenticated fine, but note it is the only install step that can
prompt; if `gh auth status` is unset it simply fails and `|| true` should wrap
it. On a work machine behind SSO this is the first thing that will complain.

## 7.48 `home/dot_local/bin/executable_tmux-sessionizer`

Rewritten. The old script branches on `uname` to choose between exactly one
hard-coded directory per OS (`~/Developer/projects` on macOS, `~/dev/projects`
elsewhere), so it finds nothing on any machine whose projects live anywhere
else — including the work box, where they will not. It also loses the `Z`
binding's companion script, which never existed (§7.37).

```bash
#!/usr/bin/env bash
# Pick a project directory and attach a tmux session to it.
#
# Sources, in order, deduplicated:
#   1. every immediate subdirectory of each root in $TS_SEARCH_PATHS
#   2. zoxide's frecency list, if zoxide is installed
#
# Override the roots per machine from ~/.config/sh/local.sh:
#   export TS_SEARCH_PATHS="$HOME/work/repos:$HOME/dev/projects"
set -euo pipefail

DEFAULT_PATHS="$HOME/dev/projects:$HOME/Developer/projects:$HOME/src:$HOME/work"
IFS=':' read -r -a roots <<< "${TS_SEARCH_PATHS:-$DEFAULT_PATHS}"

candidates() {
    for root in "${roots[@]}"; do
        [ -d "$root" ] || continue
        find "$root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
    done
    command -v zoxide >/dev/null 2>&1 && zoxide query -l 2>/dev/null
}

if [ $# -eq 1 ]; then
    selected=$1
else
    selected=$(candidates | awk '!seen[$0]++' \
        | fzf --reverse --header "sessionizer" --preview 'ls -1 {} | head -40') || true
fi

[ -z "${selected:-}" ] && exit 0
[ -d "$selected" ] || { echo "tmux-sessionizer: not a directory: $selected" >&2; exit 1; }

# tmux session names cannot contain . or :
session=$(basename "$selected" | tr '.:' '__')

# `new-session -A` attaches if it exists and creates it otherwise, which
# replaces the has_session/new/switch dance the old script open-coded.
if [ -z "${TMUX:-}" ]; then
    tmux new-session -A -s "$session" -c "$selected"
    exit 0
fi

if ! tmux has-session -t="$session" 2>/dev/null; then
    tmux new-session -ds "$session" -c "$selected"
    # Per-project or global hydration hook, unchanged from the old script.
    for hook in "$selected/.tmux-sessionizer" "$HOME/.tmux-sessionizer"; do
        if [ -f "$hook" ]; then
            tmux send-keys -t "$session" "source $hook" C-m
            break
        fi
    done
fi

tmux switch-client -t "$session"
```

Three defects fixed beyond the search paths: `has_session` grepped
`^$1:` against `list-sessions`, which fails when no server is running (the
`grep` gets empty input but `tmux list-sessions` exits non-zero first);
`tmux_running=$(pgrep tmux)` matched *any* user's tmux on a shared work box; and
neither `$selected` nor `$session` was quoted, so a project directory with a
space in it broke the script.

## 7.49 `home/dot_local/bin/executable_tmux-windowizer`

Carried over with quoting fixes only. Its job — open a named window in the
current session and `cd` into a matching directory — is exactly the git-worktree
workflow, and workmux now does the same thing more thoroughly. It stays because
it works without workmux, which matters on a box where workmux is not installed.

```bash
#!/usr/bin/env bash
# Open (or reuse) a tmux window named after $1, cd into it if it is a
# directory, and run the remaining arguments there.
#
#   tmux-windowizer feature/foo cargo test
set -euo pipefail

[ $# -ge 1 ] || { echo "usage: tmux-windowizer <name> [command...]" >&2; exit 1; }

branch_name=$(basename "$1")
session_name=$(tmux display-message -p "#S")
clean_name=$(echo "$branch_name" | tr './' '__')
target="$session_name:$clean_name"

if ! tmux has-session -t="$target" 2>/dev/null; then
    tmux neww -dn "$clean_name"
fi

shift
if [ -d "$branch_name" ]; then
    tmux send-keys -t "$target" "cd '$branch_name'" Enter
fi
[ $# -gt 0 ] && tmux send-keys -t "$target" "$*" Enter
```

The old version ended with `tmux send-keys -t $target "$*"` and no `Enter`, so
the command was typed into the window and left unexecuted. Whether that was
deliberate is unclear; sending `Enter` matches what the docstring describes. If
the type-but-do-not-run behaviour was intentional, drop the trailing `Enter`.

## 7.50 `home/dot_config/nvim/`

Carried over, with three edits. The config itself is not touched — it is
hand-rolled, current (uses the 0.11+ `lsp/` runtime directory), and §3 already
settled that it is the only editor config that survives.

**Do not copy** two files that are in `config/nvim/` today:

| File | Why |
|---|---|
| `init.lua.new` | A scratch draft. `.new` is not a Neovim-recognised suffix; it is dead. |
| `startup.log` | Output from a `--startuptime` run. |

**`nvim-pack-lock.json` is tracked, and that has a cost.** `vim.pack` rewrites
it whenever plugins update, so after an update `chezmoi status` shows the
lockfile as drifted until `chezmoi add ~/.config/nvim/nvim-pack-lock.json`. That
is the correct trade: an untracked lockfile means plugin versions are not
reproducible across the six machines in §4, which is most of the point. It is
the same class of manual step as `chezmoi add` after any out-of-band edit
(§11) — just add it to the update habit:

```sh
nvim -c 'lua vim.pack.update()' -c qa && chezmoi add ~/.config/nvim/nvim-pack-lock.json
```

**One required addition: `lua/theme.lua.tmpl`.** Neovim is currently the only
editor in the repo with no colourscheme at all — it runs on the built-in
default, which is why it has never matched anything else. §7.35 gives it the
same scheme as the terminal it is running inside, using `vim.pack` (already the
plugin manager here, per `nvim-pack-lock.json`) rather than a second one:

```lua
{{- $t := index .themes (.theme | default "onedark") -}}
-- Generated from .chezmoidata/themes.yaml (§7.35).
vim.pack.add({ {{ $t.nvim.plugin | quote }} })

-- pcall: on first launch vim.pack has queued the clone but the runtime path
-- is not populated yet, and a hard error here aborts the rest of init.lua.
-- The next launch picks it up.
local ok = pcall(vim.cmd.colorscheme, {{ $t.nvim.colorscheme | quote }})
if not ok then
  vim.notify("theme: " .. {{ $t.nvim.colorscheme | quote }} .. " not installed yet", vim.log.levels.WARN)
end
```

`init.lua` gains one line, first in the list so later modules can read
highlight groups that already exist:

```lua
require("theme")
```

`nvim-pack-lock.json` will pick up the theme plugin on the next launch, and
switching schemes leaves the previous theme's entry in the lockfile until
`vim.pack.del()` is run. That is untidy rather than broken — the unused plugin
is a few hundred KB and is never loaded.

**One optional addition**, for the parity set. Every other editor here binds
`<c-hjkl>` to window navigation (§7.43, §7.46, §7.51) and Neovim does not — it
has no window-navigation maps at all, so `<c-w>h` is the only way. Two lines in
`lua/keymaps.lua` close that:

```lua
for _, d in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("n", "<C-" .. d .. ">", "<C-w>" .. d)
end
```

This is safe *because* §7.37 dropped vim-tmux-navigator: nothing at the tmux
layer is intercepting `<c-h>` any more, so the map applies inside Neovim only
and terminal backspace elsewhere is untouched.

## 7.51 `home/dot_vimrc`, `dot_ideavimrc`, `dot_vsvimrc`

Three fallback configs for three places where Neovim is not available: plain
vim on a box that has not been provisioned, IntelliJ, and Visual Studio. All
carried over; three fixes between them, all of them small and all of them real.

**`dot_vimrc`** — `<leader>e` is mapped twice, forty lines apart:

```vim
nmap <leader>e :Ex<cr>      " line 25 — dead, overwritten below
...
nmap <leader>e :Lexplore<cr>
```

Keep the `:Lexplore` one, which matches `<leader>e` = "file tree" in every other
editor here, and delete the `:Ex` line. Also `set timeoutlen=100` is aggressive
enough that a two-key sequence typed at normal speed will time out; 300 is the
usual floor for leader mappings and matches what the other editors do by
default. Everything else — the netrw mappings, `<s-h>`/`<s-l>` buffer nav, the
window and split leader maps — is carried unchanged.

**`dot_ideavimrc`** — carried verbatim. It is the most thorough of the three and
already mirrors the `<leader>` set in §7.46 action-for-action, including the
`grn`/`gra`/`grr`/`gri` LSP block from Neovim 0.11 defaults. No changes.

**`dot_vsvimrc`** — one typo:

```vim
set lasttstatus=2   " -> laststatus
```

VsVim ignores unknown settings silently, so the status line has been off this
whole time. Also `inoremap z, <c-o>` and `inoremap z,p <c-r>"` are a prefix
collision — `z,` fires and `z,p` can never be reached, because the first mapping
completes as soon as `,` is typed. Whichever was wanted, only one can exist;
`z,p` is the more useful of the two (paste in insert mode) and `<c-o>` alone is
already reachable.

## 7.52 `home/dot_claude/executable_statusline-command.sh`

§7.34 tracks this file but never showed it. It runs on every statusline refresh,
and `settings.json` sets `"refreshInterval": 1` — once a second, for the life of
every session. The old version forks `jq` **ten times** per refresh, once per
field, plus `awk` twice and `git` once: thirteen processes a second.

One `jq` invocation does all ten extractions and all the number formatting.

```sh
#!/bin/sh
# Claude Code statusline. Reads the session JSON on stdin, prints one line.
#
# Runs once a second (settings.json refreshInterval), so process count is the
# only performance property that matters: one jq, one git, no awk.
input=$(cat)

# @sh-quotes every value, so a directory with a space or a quote in it cannot
# break the eval. Number formatting happens here rather than in three shell
# helpers because jq is already parsing the document.
eval "$(printf '%s' "$input" | jq -r '
  def q: tostring | @sh;
  def human:
    if   . >= 1000000 then ((. / 1000000 * 10 | floor) / 10 | tostring) + "M"
    elif . >= 1000    then ((. / 1000    * 10 | floor) / 10 | tostring) + "K"
    else tostring end;
  def pad2: tostring | if length < 2 then "0" + . else . end;

  (.context_window // {}) as $c |
  (.cost // {}) as $k |
  (((.total_duration_ms // 0) | floor) / 1000 | floor) as $secs |
  [
    "MODEL="   + ((.model.display_name // "claude") | q),
    "FOLDER="  + ((.workspace.current_dir // "" | split("/") | last // "") | q),
    "DIR="     + ((.workspace.current_dir // "") | q),
    "EFFORT="  + ((.effort.level // "") | q),
    "PCT="     + (($c.used_percentage // 0) | floor | q),
    "TOKENS="  + ((($c.total_input_tokens // 0) + ($c.total_output_tokens // 0)) | human | q),
    "MAXTOK="  + (($c.context_window_size // 200000) | human | q),
    "COST="    + ((($k.total_cost_usd // 0) * 100 | floor) / 100 | tostring | q),
    "ELAPSED=" + ((((($k.total_duration_ms // 0) | floor) / 60000 | floor) | tostring)
                  + "m " + (((($k.total_duration_ms // 0) | floor) / 1000 | floor) % 60 | pad2) + "s" | q)
  ] | join("\n")
')"

CYAN="\033[0;36m"; GREEN="\033[0;32m"; YELLOW="\033[0;33m"
RED="\033[0;31m";  BLUE="\033[0;34m";  MAGENTA="\033[0;35m"
DIM="\033[2m";     RESET="\033[0m"

BRANCH=""
if [ -n "$DIR" ] && git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
fi

case "$PCT" in
    ''|*[!0-9]*) PCT=0 ;;
esac
if   [ "$PCT" -ge 90 ]; then PCT_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then PCT_COLOR="$YELLOW"
else                         PCT_COLOR="$GREEN"
fi

case "$EFFORT" in
    max)    EFFORT_COLOR="$RED" ;;
    high)   EFFORT_COLOR="$YELLOW" ;;
    medium) EFFORT_COLOR="$GREEN" ;;
    *)      EFFORT_COLOR="$DIM" ;;
esac

SEP="${DIM} | ${RESET}"
OUT="${CYAN}${MODEL}${RESET}"
[ -n "$EFFORT" ] && OUT="${OUT}${SEP}${EFFORT_COLOR}${EFFORT}${RESET}"
OUT="${OUT}${SEP}${BLUE}${FOLDER}${RESET}"
[ -n "$BRANCH" ] && OUT="${OUT}${SEP}${MAGENTA}${BRANCH}${RESET}"
OUT="${OUT}${SEP}${PCT_COLOR}${TOKENS}/${MAXTOK} (${PCT}%)${RESET}"
OUT="${OUT}${SEP}${YELLOW}\$${COST}${RESET}"
OUT="${OUT}${SEP}${CYAN}${ELAPSED}${RESET}"

printf '%b\n' "$OUT"
```

Also fixed while here:

- `format_tokesn` — the typo was in the function name *and* both call sites, so
  it worked. It is gone with the function.
- `local n=$1` inside a `#!/bin/sh` script. `local` is not POSIX; it works in
  dash and bash but not in every `/bin/sh` this will meet on the work box.
- The branch was coloured `BLUE` here and `MAGENTA` in the PowerShell twin
  (§7.53). Both are magenta now, and `$MAGENTA` is no longer an unused variable.
- `$DIR` was interpolated unquoted into `git -C`.

## 7.53 `home/dot_claude/statusline-command.ps1`

**This file has never printed anything.** It reads stdin, parses the JSON,
computes every field, assembles `$out` — and then the file ends. There is no
`Write-Host`, no `Write-Output`, no bare `$out`. The Windows statusline has been
blank since it was written, which is also why nobody noticed the divergences
below.

```powershell
#!/usr/bin/env pwsh
# Twin of statusline-command.sh (§7.52). Keep the two output formats identical:
# model | effort | folder | branch | tokens (pct) | cost | elapsed

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }
if ($null -eq $payload) { exit 0 }

function Get-Prop {
    param($obj, [string]$path, $default = $null)
    foreach ($key in $path.Split('.')) {
        if ($null -eq $obj) { return $default }
        $prop = $obj.PSObject.Properties[$key]
        if ($null -eq $prop) { return $default }
        $obj = $prop.Value
    }
    if ($null -eq $obj) { return $default }
    return $obj
}

$model      = Get-Prop $payload 'model.display_name' 'claude'
$dir        = Get-Prop $payload 'workspace.current_dir' ''
$pctRaw     = Get-Prop $payload 'context_window.used_percentage' 0
$usedIn     = [long](Get-Prop $payload 'context_window.total_input_tokens' 0)
$usedOut    = [long](Get-Prop $payload 'context_window.total_output_tokens' 0)
$max        = [long](Get-Prop $payload 'context_window.context_window_size' 200000)
$effort     = Get-Prop $payload 'effort.level' ''
$cost       = [double](Get-Prop $payload 'cost.total_cost_usd' 0)
$durationMs = [long](Get-Prop $payload 'cost.total_duration_ms' 0)

$pct = [int][math]::Floor([double]$pctRaw)

$ESC = [char]27
$CYAN = "${ESC}[36m"; $GREEN = "${ESC}[32m"; $YELLOW = "${ESC}[33m"
$RED = "${ESC}[31m";  $BLUE = "${ESC}[34m";  $MAGENTA = "${ESC}[35m"
$DIM = "${ESC}[2m";   $RESET = "${ESC}[0m"

$folder = if ($dir) { ($dir -split '[\\/]')[-1] } else { '' }

$branch = ''
if ($dir -and (Test-Path $dir) -and (Get-Command git -ErrorAction SilentlyContinue)) {
    git -C "$dir" rev-parse --git-dir 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $branch = git -C "$dir" branch --show-current 2>$null }
}

$pctColor = if ($pct -ge 90) { $RED } elseif ($pct -ge 70) { $YELLOW } else { $GREEN }

$effortColor = switch ($effort) {
    'max'    { $RED }
    'high'   { $YELLOW }
    'medium' { $GREEN }
    default  { $DIM }
}

function Format-Tokens {
    param([long]$n)
    # Decimal, not binary. 1MB/1KB in PowerShell are 1048576/1024, which made
    # this disagree with the sh twin by 5% at every magnitude.
    if ($n -ge 1000000) { return ('{0:0.0}M' -f ($n / 1000000)) }
    elseif ($n -ge 1000) { return ('{0:0.0}K' -f ($n / 1000)) }
    else { return "$n" }
}

$usedFmt = Format-Tokens ($usedIn + $usedOut)
$maxFmt  = Format-Tokens $max
$costFmt = '${0:0.00}' -f $cost

$durationSec = [long][math]::Floor($durationMs / 1000)
$durationFmt = '{0}m {1:00}s' -f [long][math]::Floor($durationSec / 60), ($durationSec % 60)

$SEP = "${DIM} | ${RESET}"
$out = "$CYAN$model$RESET"
if ($effort) { $out += "$SEP$effortColor$effort$RESET" }
$out += "$SEP$BLUE$folder$RESET"
if ($branch) { $out += "$SEP$MAGENTA$branch$RESET" }
$out += "$SEP$pctColor$usedFmt/$maxFmt ($pct`%)$RESET"
$out += "$SEP$YELLOW$costFmt$RESET"
$out += "$SEP$CYAN$durationFmt$RESET"

# The line the original was missing.
Write-Host $out
```

**Which one runs.** `settings.json` (§7.34) hard-codes
`"command": "sh ~/.claude/statusline-command.sh"`, so the `.ps1` is only reached
on a native-Windows machine whose `settings.json` overrides it. That override is
not currently in the repo. Either add a templated `statusLine.command` to §7.34:

```
"command": {{ if eq .chezmoi.os "windows" }}"pwsh -NoProfile -File ~/.claude/statusline-command.ps1"{{ else }}"sh ~/.claude/statusline-command.sh"{{ end }},
```

— which turns `settings.json` into `settings.json.tmpl` — or accept that native
Windows uses `sh` from Git for Windows and delete the `.ps1` entirely. **Decide
in step 3.** Note that the working tree already has this file as
`dot_claude/settings.json.tmpl`, so the templated form is the one in flight.

## 7.54 `home/dot_claude/skills/` and `home/dot_claude/agents/`

§7.34 established *how* these are tracked (plain directories, never `exact_`,
because a work machine's own skills and agents live in the same folders). This
is *what* is tracked, because "copy the directory" is not a specification when
half its contents on any given machine are not ours.

### Skills — 13, from `claude/skills/` in the old repo

| Skill | What it does |
|---|---|
| `caveman` | Terse-output mode |
| `diagnose` | Reproduce → minimise → fix loop for hard bugs and perf regressions |
| `grill-me` | Interrogates a plan or design until it holds up |
| `grill-with-docs` | Same, against the existing domain model and docs |
| `handoff` | Compacts a conversation into a handoff document |
| `improve-codebase-architecture` | Finds deepening opportunities, informed by `CONTEXT.md` |
| `prototype` | Throwaway prototype before committing to a design |
| `tdd` | Red-green-refactor loop |
| `to-issues` | Splits a plan into independently-grabbable tracker issues |
| `to-prd` | Turns conversation context into a PRD |
| `triage` | Issue triage state machine |
| `write-a-skill` | Scaffolds new skills |
| `zoom-out` | Forces a higher-level perspective |

Each is a directory with a `SKILL.md`; `diagnose` also carries
`scripts/hitl-loop.template.sh`. They move as directories, so bundled resources
come along without enumeration:

```sh
git mv ../dotfiles/claude/skills home/dot_claude/skills
```

`hitl-loop.template.sh` needs no `executable_` prefix — it is a template read by
the skill, not a script anything runs directly. If that changes, it needs the
prefix, or it will land mode 0644 and fail.

### Agents — 9, currently tracked nowhere

These exist only in the live `~/.claude/agents/` and would be lost on the next
machine rebuild. That is the whole reason this section exists.

| Agent | Domain |
|---|---|
| `api-documenter` | OpenAPI 3.1, developer portals |
| `architect-review` | Clean architecture, microservices, DDD |
| `backend-architect` | REST APIs, service boundaries, schemas |
| `code-reviewer` | Security, performance, config review |
| `cpp-pro` | Modern C++, RAII, templates, move semantics |
| `debugger` | Errors, test failures, unexpected behaviour |
| `docs-architect` | Long-form technical documentation from a codebase |
| `error-detective` | Log and stack-trace correlation |
| `mermaid-expert` | Diagrams |

Capture them once, before the old tree is deleted:

```sh
mkdir -p home/dot_claude/agents
cp ~/.claude/agents/*.md home/dot_claude/agents/
```

`cpp-pro`, `debugger`, `code-reviewer`, and `architect-review` line up with the
C++/Java/Rust work these machines are for; the rest are general. Nothing here is
work-specific — that is the point of the split in §7.34, and it is worth
re-checking at capture time that no agent file names an internal system.

### Not tracked

Everything else under `~/.claude`, per the §7.34 allowlist. Worth naming
explicitly, because they look like config and are not: `plugins/` (installed
from marketplaces, declared by `enabledPlugins` in `settings.json`), `commands/`
(empty on personal machines, work-specific where it is not), `.credentials.json`,
and `mcp.json`.

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
config/nvim-custom/    (a stray .claude/settings.local.json, nothing else)
```

Deleted by the §7 rewrites, listed separately because they are not obviously
dead until you have read those sections:

```
config/bat/themes/*.tmTheme    inert without `bat cache --build` (§7.41);
                               the two schemes that need one now fetch it
                               from upstream via .chezmoiexternal
config/nvim/init.lua.new       scratch draft (§7.50)
config/nvim/startup.log        --startuptime output (§7.50)
config/zed/prompts/            LMDB prompt library — runtime state (§7.45)
config/zed/conversations/      agent transcripts — runtime state (§7.45)
config/zed/themes/             empty; themes now come from §7.35
git/gitignore                  never wired to anything → §7.42
```

Expected result: 155 tracked files → roughly 55–65. The theme mechanism adds
files but removes more: four bat themes and five palettes-in-configs collapse
into one `themes.yaml` row set.

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

Then the two things the rewrites introduced:

- **Plugins load without tpm.** `tmux show -g @resurrect-dir` returns the XDG
  path. If it is empty, the `run-shell` guards in §7.37 found nothing and the
  externals did not fetch — check `chezmoi apply --refresh-externals`.
- **The theme round-trips.** `theme dracula`, confirm wezterm, tmux (after
  `prefix-r`), lazygit, starship, fzf, bat, and delta all change; then
  `theme onedark` and confirm they change back. This exercises every consumer
  in §7.35 at once and is much faster than checking them individually later.
  Zed and VS Code lag by one restart — expected, per §7.35.

**Step 2 — headless role, same box.** Set `role = "headless"` in a scratch config and run `chezmoi diff`. Confirm the wezterm/zed/Code targets are absent from the diff entirely. Validates the role split without a second machine.

**Step 3 — Windows, same physical machine.** Install chezmoi and pwsh, then `chezmoi init --apply`. **Verify the XDG bet explicitly before proceeding:** confirm nvim, wezterm, git, bat, and opencode each read from `~/.config`. Anything that does not gets a Windows-specific target path and a note here. This is the design's largest untested assumption.

Two of the original unknowns here are now settled rather than open: lazygit is
pinned by `LG_CONFIG_FILE` (§7.39), and VS Code is known *not* to honour XDG on
Windows, which §7.43 handles with a separate `AppData/Roaming` target. Confirm
both rather than investigate them. Also decide the §7.53 question — whether
`settings.json` templates its `statusLine.command` to pwsh, or the `.ps1` goes.

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

**The XDG-on-Windows bet.** nvim, wezterm, git, bat, and opencode are confirmed. starship, mise, and lazygit are pinned by env var and so are immune. VS Code is the one confirmed *failure* — it ignores XDG on both macOS and Windows and offers no override — which §7.43 absorbs with three target paths sharing one body. The bet held for everything except the one GUI application, which is roughly what should have been expected.

**The theme variable is a third axis.** §12 already warns that `work` is a third axis on top of role × platform and earns exactly one flat line in `.chezmoiignore`. `theme` is a fourth, and it earns *zero* — it changes file contents, never which files exist. Keep it that way. The moment a theme starts excluding a file, it has become a role, and the matrix goes from 2×4 to 2×4×4.

**Eleven consumers is the ceiling.** Every tool added to §7.35's table is another place a colour can be wrong in a way nothing detects. The `theme` round-trip in step 1 is the only test there is, and it is a manual one. If the list grows much past eleven, the answer is a rendered contact sheet — apply each scheme to a scratch destination and diff — not more careful reading.

**Over-templating.** Template only where files genuinely differ; prefer separate files plus `.chezmoiignore` over inline conditionals. More than one level of nesting means split the file.

**No package removal.** Deleting from `packages.yaml` never uninstalls. If this becomes a real problem, add a reconciliation script that diffs installed against declared — do not reach for Nix, which cannot serve the Windows half.

**Branch longevity.** Timebox steps 1–3 to about a week and merge once two machines are migrated, rather than waiting for all six.
