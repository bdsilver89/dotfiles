# Replacing chezmoi with a single bash installer

## Status

`install.sh` and `install.ps1` are written. `install.sh` is verified against
bash 3.2 on macOS: linking, idempotent re-runs, all four conflict modes, the
interactive menu, and `--dry-run` all behave. `install.ps1` is **unverified** —
no PowerShell available on the machine it was written on.

The repo **has been migrated**: real dotfile names, no chezmoi machinery, no
templates. A dry run links 28 targets cleanly. What remains is the `README.md`
rewrite and verifying `install.ps1` on a Windows box.

## Goal

One `install.sh` that provisions a fresh macOS or Linux (RHEL-family or
Debian-family) machine from this repo, runnable both as a checked-out script and
as a `curl`-piped one-liner. A parallel `install.ps1` covers Windows.

## What chezmoi is doing today

Five distinct jobs, all of which the replacement has to cover:

| Job | Chezmoi mechanism | Replacement |
| --- | --- | --- |
| Place files in `$HOME` | `dot_` / `executable_` / `symlink_` name prefixes, copied on `apply` | Symlinks, real filenames, repo file modes |
| Vary content per machine | 16 Go templates | Removed entirely — see [Killing the templates](#killing-the-templates) |
| Exclude files per OS | `.chezmoiignore` | Explicit per-OS entries in the symlink map |
| Fetch third-party content | `.chezmoiexternal.toml.tmpl` | `fetch_externals`, pinned versions |
| Run ordered setup steps | 13 `run_onchange_*` scripts | Ordered functions in `install.sh` |

The data file `.chezmoidata/packages.yaml` feeds most of those scripts; it becomes
bash arrays inline in `install.sh`.

## Decisions

| Question | Decision |
| --- | --- |
| Deploy mechanism | **Symlink.** Edit in place, `git status` is the source of truth, no apply step. |
| File naming | **Real dotfile names.** `home/.zshrc`, not `home/dot_zshrc`. One big `git mv` commit. |
| Windows | **Kept**, as a separate `install.ps1`. Not covered by the bash script. |
| Desktop vs headless | **Auto-detect**, `--desktop` / `--headless` override. No prompt, so `curl \| bash` works unattended. |
| Script structure | **Truly single file.** Package lists inline. No sourced helpers. |
| Bootstrap | **Self-cloning.** Same file detects it is running outside a checkout, clones, re-execs. |
| Externals | **Downloaded at install time, versions pinned** in the script. |
| Conflicts | **Interactive menu** per file, single keypress, read from `/dev/tty`; falls back to backup-and-link when there is no tty. Backups are adjacent (`~/.zshrc.backup`). |
| Symlink granularity | **Per directory choice**: `add_tree` for directories we own outright, `add_entries` for any directory that also holds machine-local files. |
| Machine-local files | Ordinary files inside an `add_entries` directory. Never gitignored-in-repo. |

## Killing the templates

All 16 templates go away. None of them need a template engine; each has a
tool-native equivalent that this repo already half-uses.

**`dot_gitconfig.tmpl`** — the only conditional is `core.autocrlf = input` on
Windows. `~/.gitconfig` already starts with `[include] path = ~/.gitconfig.local`,
so `install.ps1` writes that one setting into `~/.gitconfig.local` and the
template becomes a plain file.

**`dot_config/alacritty/alacritty.toml.tmpl`** — the only conditionals are font
family and size. The config already imports `~/.config/alacritty/machine.toml`,
which is documented as the untracked per-machine override. The installer writes
font family and size into `machine.toml` if that file does not exist yet. Plain
file.

**`dot_config/mise/config.toml.tmpl`** — becomes a plain tracked
`home/.config/mise/config.toml`, symlinked like any other config. Two things
make this work, both verified against mise 2026.8.6:

- `mise use -g` writes *through* the symlink rather than replacing it, so a tool
  you add ad hoc lands in the repo as an ordinary diff you can commit. Under
  chezmoi it was silently reverted on the next apply.
- `~/.config/mise/conf.d/*.toml` is merged with `config.toml`, which gives
  machine-local tools a home outside the repo.

One conditional cannot live in a static file: `eza` has no EPEL package, and
mise can only build it from source (`cargo:eza`), so it is worth doing on the
RHEL rebuilds and not worth it anywhere else. `write_mise_platform_config`
writes that single tool as a `conf.d/00-platform.toml` drop-in, and removes the
file on platforms that do not need it.

**20 × `dot_claude/skills/symlink_*.tmpl`** — each contains exactly
`{{ .chezmoi.homeDir }}/.agents/skills/<name>`. Replaced by a loop over
`home/.agents/skills/*`. This also retires the `.chezmoiignore` allowlist that had
to be hand-edited every time a skill was added — the loop derives the list from
the filesystem, so there is nothing to keep in sync.

**13 × `run_onchange_*.tmpl`** — become functions. The `{{ if ne .chezmoi.os
"windows" }}` guards vanish (the bash script is never run on Windows) and the
`{{ range }}` loops become `for` loops over arrays.

## Layout after migration

```
install.sh                     # single entry point, curl-able, self-cloning
install.ps1                    # windows only
Brewfile                       # macOS-only packages; not a dotfile, not linked
README.md                      # rewritten; current one is chezmoi-specific throughout
docs/bash-install-plan.md      # this file
home/
  .bash_profile .bashrc .profile .zshenv .zshrc .vimrc .tmux.conf .gitconfig
  .config/
    alacritty/{alacritty.toml,catppuccin-mocha.toml}
    ghostty/config
    wezterm/wezterm.lua
    workmux/config.yaml
    nvim/{init.lua,stylua.toml}
    vim/notes/
    tmux/*.sh                  # chmod +x in repo
    zsh/{00-completion,10-history,20-keybinds,30-plugins}.zsh
    sh/{00-path,10-env,15-tools,20-aliases}.sh
    starship.toml
  .claude/settings.json        # merged, never linked
  .agents/skills/<20 skills>/
  .local/bin/tmux-*            # chmod +x in repo
AppData/Roaming/alacritty/     # windows only, consumed by install.ps1
```

Deleted: `.chezmoiroot`, `home/.chezmoi.toml.tmpl`, `home/.chezmoiexternal.toml.tmpl`,
`home/.chezmoiignore`, `home/.chezmoidata/`, all `home/run_onchange_*`, all
`home/dot_claude/skills/symlink_*.tmpl`.

## Symlink map

| Target in `$HOME` | Mode | Rationale |
| --- | --- | --- |
| `.bashrc`, `.zshrc`, `.profile`, `.zshenv`, `.bash_profile`, `.vimrc`, `.tmux.conf`, `.gitconfig` | file | one-to-one |
| `.config/nvim` | **dir** | fully ours; `vim.pack` stores plugins under `~/.local/share/nvim`, so nothing is written back into the config dir |
| `.config/ghostty`, `.config/workmux`, `.config/zsh`, `.config/sh`, `.config/tmux`, `.config/opencode` | **dir** | fully ours |
| `.pi` | **dir** | a project directory you edit in the repo; npm writes `node_modules` into it, which `.gitignore` covers |
| `.config/alacritty` | **per entry** | holds `machine.toml` |
| `.config/wezterm` | **per entry** | holds `machine.lua` — SSH hosts, must never be committed |
| `.config/starship.toml` | file | `.config` itself is shared with everything else |
| `.config/mise` | **per entry** | `config.toml` is tracked and linked; `conf.d/` stays real for machine-local tools and the generated platform drop-in |
| `.local/bin/*` | **per entry** | dir is shared with brew/mise/vendor shims |
| `.claude/settings.json` | **jq-merged** from `home/.claude/settings.baseline.json` | Claude Code rewrites it as you approve permissions; a symlink would put its churn in the repo |
| `.agents/skills` | **dir** | fully ours |
| `.claude/skills/<name>`, `.opencode/skills/<name>` | file each → `~/.agents/skills/<name>` | dirs are shared with local/work-only skills |

### One config change this forces

`~/.config/tmux` is both ours (5 scripts) and, today, the destination chezmoi
downloads the catppuccin theme and `vim-tmux-navigator.tmux` into. Those cannot
coexist with a directory symlink — the downloads would land inside the repo.

Fix: move the externals to `${XDG_DATA_HOME:-$HOME/.local/share}/tmux/` and change
the two `run-shell` lines in `home/.tmux.conf`:

```diff
-run-shell "$HOME/.config/tmux/plugins/catppuccin/catppuccin.tmux"
+run-shell "${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/catppuccin/catppuccin.tmux"
@@
-run-shell "$HOME/.config/tmux/vim-tmux-navigator.tmux"
+run-shell "${XDG_DATA_HOME:-$HOME/.local/share}/tmux/vim-tmux-navigator.tmux"
```

This also matches where the zsh plugins already go, so all downloaded content
ends up under one root.

## Where a package goes

The design driver is the number of edits it takes to add one thing. Every case
below is a single edit, and the lists are split so that no package ever needs to
appear in two places.

| To add | Edit | Applies to |
| --- | --- | --- |
| a cross-platform CLI tool | `PKGS_CORE` in `install.sh` | brew, apt and dnf from one name |
| a tool better taken from mise | `home/.config/mise/config.toml` | everywhere |
| a macOS GUI app or mac-only formula | `Brewfile` | macOS, desktop role |
| a Linux GUI app | `PKGS_DESKTOP_LINUX` in `install.sh` | apt and dnf, desktop role |
| a gh extension, zsh plugin or vendor tool | its list in `install.sh` | everywhere |

**Why `Brewfile` is a file but the apt/dnf lists are not.** Giving apt and dnf
their own manifests would make a cross-platform tool a two- or three-edit
change, which is exactly what this layout is trying to avoid. `Brewfile` earns
its place because nothing in it has a Linux counterpart -- casks and mac-only
formulae -- so it is never the second edit. `brew bundle` also handles casks and
taps natively, which an inline list does not.

`Brewfile` lives at the repo root rather than under `home/`, because `home/`
means "things linked into `$HOME`" and this is installer input.

**Why `fd` and `gh` come from mise.** They were the only two packages that cost
extra code. `fd` is called `fd-find` on both apt and dnf and was the sole entry
in a `pkg_name` mapping function; `gh` has no package on the RHEL rebuilds and
needed its own repo added with two different `dnf config-manager` spellings to
cover dnf5. Both have `aqua:` backends -- prebuilt binaries from upstream
releases, not source builds -- so moving them deleted `pkg_name` outright and
about eight lines of RHEL repo setup, and gets current versions on distros that
ship ancient ones.

This also removes a conflict the shell config already defends against:
`.config/sh/15-tools.sh` carries a comment about "a stale fzf earlier on PATH
(e.g. distro package ahead of the mise shim)". Anything taken from exactly one
source cannot hit that.

Because mise installs into `$XDG_DATA_HOME/mise/shims` rather than
`~/.local/bin`, `main` puts the shim directory on `PATH` before running any
phase -- otherwise `install_gh_extensions` would not find `gh`, and neither
would `--only=gh` run on its own.

**What stays on the system package manager.** `git` and `zsh` are not in mise's
registry at all, and `zsh` is a login shell that belongs in `/etc/shells`.
`eza`'s only backends are `cargo:` and `vfox:`, so mise would build it from
source -- it is taken from the distro everywhere except the RHEL rebuilds, which
have no package for it, where `write_mise_platform_config` falls back to mise.
`tmux` was considered and rejected: it links against system ncurses and terminfo,
and a static build is a downgrade for no real gain.

## Phase order

Same order as the current `run_onchange_before_*` / `run_onchange_after_*`
numbering, since that ordering is already load-bearing (mise must exist before
`mise install`; `gh` must be installed before `gh extension install`).

1. `detect_platform` — os, distro family, arch
2. `detect_role` — desktop vs headless
3. `bootstrap_repo` — clone and re-exec if piped from curl
4. `install_packages` — brew / apt / dnf, plus desktop packages
5. `install_mise` — bootstrap binary, `write_mise_platform_config`, `mise install`
6. `link_dotfiles` — the symlink pass
7. `fetch_externals` — catppuccin tmux, vim-tmux-navigator
8. `install_zsh_plugins` — autosuggestions, syntax-highlighting
9. `install_vendor` — claude, rtk (bootstrap only; they self-update)
10. `install_gh_extensions`
11. `merge_claude_settings`
12. `link_skills` — claude + opencode skill links
13. `init_rtk`

## Constraints worth knowing before writing code

**macOS ships bash 3.2.** No associative arrays, no `mapfile`, no `${var,,}`.
Everything below is bash 3.2 compatible. This is the single easiest way to write
a script that works on your Linux boxes and fails on your laptop.

**`curl | bash` has no usable stdin.** The script *is* stdin. All prompts read
from `/dev/tty` explicitly, and degrade when it is not readable.

**Idempotency is per-phase, not global.** Every phase must be safe to re-run;
`--only=<phase>` exists so you can re-run one.

## Implementation

`install.sh` is the implementation and the source of truth. It is written for
bash 3.2 and verified against `/bin/bash` on macOS. What follows are the design
notes that are not obvious from reading it.

### Logging

Right-aligned past-tense verb in an 11-column gutter, subject flush after.
Colour is emitted *before* the padding so escapes do not count toward `%*s` —
the usual reason aligned bash output goes ragged once colour is on.

Three rules keep it readable:

1. **Verbs are past tense and short.** `Linked`, `Wrote`, `Skipped`,
   `Backed up`, `Installed`, `Cloned`, `Fetched`, `Merged`, `Warning`, `Error`.
   Longer than 11 characters breaks the gutter, so the vocabulary is closed.
2. **Unchanged things are silent** unless `--verbose`. A second run prints about
   12 lines, not 60.
3. **Subprocess output is captured, not streamed.** `quietly` runs a command
   silently and replays the last 20 lines only on failure. It deliberately does
   *not* warn — the caller decides whether a non-zero exit matters, so a
   failure is never counted twice.

```
dotfiles  darwin/arm64 - desktop - ~/dotfiles

   Packages
 Installing homebrew
  Installed git tmux fzf ripgrep fd bat eza zoxide and 3 more
    Skipped desktop casks (headless)

    Linking
     Linked ~/.zshrc
     Linked ~/.config/alacritty/alacritty.toml
  Backed up ~/.gitconfig.backup
    Warning ~/.local/bin/tmux-agents missing in repo

   Finished 23 linked - 4 unchanged - 1 backed up - 1 warning - 41s
```

### Link granularity, and machine-local files

The link map offers two granularities, taken from the old `bootstrap.sh`'s
`link_files_in_dir` depth argument:

- `add_tree <dir>` symlinks the directory itself. Anything written into it
  lands **inside the repo**, so this is only for directories where the repo
  owns every entry.
- `add_entries <dir>` symlinks each entry, leaving the directory itself real.
  Machine-local files sit beside the links and never enter the repo.
- `add_files <dir>` symlinks each *file*, recreating the repo's directory
  structure as real directories. The safest granularity: live content can
  coexist at any depth.

The last two cost a re-run of `--only=links` when a file is added to the repo.

Choosing wrongly here is the one thing in this design that can lose data, so the
map was checked against what is actually in `$HOME` rather than assumed. That
check caught four directories mapped as `add_tree` that hold untracked live
content: `.config/nvim` (`nvim-pack-lock.json`, `notes/`, `pluginx/` — `vim.pack`
does write into the config dir, contrary to an earlier note here),
`.config/sh` (a machine-local `30-tools.sh`), `.config/opencode` (an entire npm
project), and `.pi` (`agent/auth.json`, `agent/sessions/`, `agent/skills/`).
All four are `add_files`.

This is the answer to "where do machine-specific files go": they go in an
`add_entries` directory, as ordinary files.

| Directory | Granularity | Why |
| --- | --- | --- |
| `.config/ghostty`, `workmux`, `zsh`, `.agents/skills` | `add_tree` | repo owns every entry; verified zero live-only files |
| `.config/nvim`, `.config/sh`, `.config/tmux`, `.config/opencode`, `.pi` | `add_files` | hold untracked live state at varying depths |
| `.config/alacritty` | `add_entries` | holds `machine.toml`, imported by `alacritty.toml` |
| `.config/wezterm` | `add_entries` | holds `machine.lua` — SSH hosts and usernames, the one thing that must never be committed |
| `.config/mise` | `add_entries` | holds `conf.d/*.toml` |
| `.local/bin` | `add_entries` | shared with brew, mise and vendor shims |
| `.agents/skills` | `add_tree` | fully ours |
| `.claude/skills`, `.opencode/skills` | per-entry, via `link_skills` | shared with local/work-only skills |

`~/.gitconfig.local` needs no special handling: it is a top-level file in
`$HOME` and `.gitconfig` is linked individually.

### Conflicts

`resolve_conflict` sets a global rather than echoing a value — a `$( )` subshell
would discard `CONFLICT_ALL`, so "apply to all remaining" would silently apply
to exactly one file. Single keypress, no Enter, as the old script did. Backups
are written adjacent (`~/.zshrc.backup`, suffixed with a timestamp if that
already exists) rather than into a directory you have to go find.

With no tty — `curl | bash`, CI, provisioning — the menu is skipped and backup
is used.

### Other things taken from the old bootstrap.sh

- **`check_package_availability`** → `available_packages`. Probes each package
  before installing, because one name missing from a repo fails the whole
  transaction, and repo contents vary a lot across the RHEL rebuilds. The
  missing ones are reported and skipped.
- **`is_wsl`** → WSL is treated as headless. It reports a display under WSLg
  but has no use for native GUI packages.
- **`update`** as its own step, opt-in only (`--only=update`). An automatic
  `git pull` on every install would clobber uncommitted local work.

`--only=prune-backups` is the other opt-in step. It deletes `*.backup` files
whose content the repo already has, and keeps any that differ, listing them.
It walks the link map rather than the filesystem, so it can only touch paths
this script created -- and it needs no `find(1)` time predicates, which BSD
find rejects in GNU's relative form anyway.

### Subshells

`warn` increments `N_WARNINGS`, so any loop that calls it cannot run in a
subshell. `install_zsh_plugins` and `install_vendor` therefore read their
`name|url|ref` tables from a heredoc rather than a pipe.

## install.ps1 outline

Not a port of the bash script — Windows only needs a small subset. Winget
packages, the `AppData/Roaming/alacritty` link, and the one git setting that used
to be a template conditional.

```powershell
$ErrorActionPreference = "Stop"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found; install App Installer from the Microsoft Store"
    exit 1
}

$packages = @(
    "Alacritty.Alacritty",
    "Microsoft.VisualStudioCode",
    "ZedIndustries.Zed",
    "DEVCOM.JetBrainsMonoNerdFont"
)

foreach ($id in $packages) {
    # Native commands ignore $ErrorActionPreference, so exit codes are checked
    # by hand. `winget install` on an already-installed package exits non-zero,
    # hence the `winget list` probe.
    winget list --id $id --exact --accept-source-agreements *> $null
    if ($LASTEXITCODE -eq 0) { continue }

    winget install --id $id --exact --silent `
        --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { Write-Error "winget install $id failed"; exit 1 }
}

# Replaces the autocrlf conditional that used to live in dot_gitconfig.tmpl.
# ~/.gitconfig already includes ~/.gitconfig.local.
$gitLocal = Join-Path $HOME ".gitconfig.local"
git config --file $gitLocal core.autocrlf input

# Symlinks need Developer Mode or an elevated shell on Windows.
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
New-Item -ItemType SymbolicLink -Force `
    -Path (Join-Path $env:APPDATA "alacritty") `
    -Target (Join-Path $repo "AppData\Roaming\alacritty") | Out-Null
```

## Migration steps

1. **Rename pass, one commit.** `git mv` every `dot_*` to its real name, strip
   `executable_` prefixes and `chmod +x` those files, delete `.chezmoiroot`,
   `home/.chezmoi*`, `home/run_onchange_*`, and the 20 `symlink_*.tmpl`.
   Verify with `git log --follow` on a couple of files afterwards.
2. **Repo `.gitignore` check.** Real dotfile names must not be swallowed by an
   ignore rule. Add `home/.config/alacritty/machine.toml`.
3. **`.tmux.conf` external paths** — the two `run-shell` lines above.
4. **Write `install.sh`** from this document.
5. **Write `install.ps1`.**
6. **Rewrite `README.md`** — 14K, chezmoi-specific throughout.
7. **Test:** `./install.sh --dry-run` on this Mac, then `--only=links` for real,
   then a full run in a Ubuntu and a Rocky container.

## Open questions

1. Does `bootstrap_repo` need to forward `"$@"` through the `exec`, or should the
   curl path always run with defaults? (Currently it forwards.)
2. ~~Keep the `file`/`dir` type field in the link map?~~ **Resolved.** Replaced by
   `add_tree` / `add_entries`, which expand at map-build time, so `link_one`
   needs no type at all.
3. Pin `vim-tmux-navigator` to a commit SHA, or track `master` like the current
   168h-refresh external? (Currently `master`.)
4. ~~`install_zsh_plugins` uses `| while`, a subshell.~~ **Resolved.** `warn`
   increments `N_WARNINGS`, which a subshell would discard, so it and
   `install_vendor` read from a heredoc.
5. Should `link_skills` prune stale links whose target has been deleted from
   `~/.agents/skills`? Chezmoi did this for free; the loop does not.
6. ~~`.claude/settings.json` needs a decision.~~ **Resolved: baseline-only.**
   `home/.claude/settings.baseline.json` is tracked and merged into
   `~/.claude/settings.json`, which is never linked and never tracked, so
   permissions Claude adds while working are not repo diffs.

   Worth recording why the baseline is the *former tracked file* and not the
   heredoc from `run_onchange_after_10-claude-settings.sh.tmpl`: the tracked
   file was not merely post-merge drift. It carried a `hooks` block the heredoc
   never had — the `tmux-agent-status` Notification/Stop/UserPromptSubmit hooks
   and the `rtk` PreToolUse hook — plus `modelSettings`. Permission sets were
   identical (26 allow, 7 deny); the only key the heredoc had that the tracked
   file lacked was `effortLevel: low` against the tracked `medium`. Taking the
   heredoc would have silently dropped the hooks.

7. `install.ps1` is unverified and its link map is a guess (`.gitconfig`,
   `.vimrc`, `AppData/Roaming/alacritty`). What does Windows actually need?
