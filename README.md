# dotfiles

Cross-platform shell, editor, terminal, and CLI configuration for macOS,
Debian/Ubuntu, RHEL/Fedora, Windows, and WSL.

The repository uses a small platform-aware installer rather than chezmoi. It
links or copies files from `home/`, installs packages and tools, and preserves
local changes according to the selected conflict policy.

## Install

macOS and Linux:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/bdsilver89/dotfiles/main/install.sh)"
```

The script clones or updates `~/dotfiles` and detects the platform and role.
Use `--desktop` for GUI applications or `--headless` to skip them. WSL is
treated as headless; configure Windows applications from PowerShell instead.

Windows PowerShell (clone the repository first):

```powershell
git clone https://github.com/bdsilver89/dotfiles.git "$HOME\dotfiles"
& "$HOME\dotfiles\install.ps1"
```

Run `./install.sh --help` or `./install.ps1 -Help` for all options. Useful
options include `--dry-run`, `--verbose`, `--on-conflict=backup`, and
`--only=PHASE`.

## What Gets Installed

- Homebrew on macOS; apt on Debian/Ubuntu; dnf on Fedora/RHEL derivatives.
- Core CLI tools such as git, tmux, fzf, ripgrep, bat, eza, zoxide, jq, and
  zsh.
- mise-managed tools and runtimes from `home/.config/mise/config.toml`,
  including Neovim, Starship, Lazygit, Workmux, gh, Node, Python, Rust,
  OpenCode, Pi, Lazydocker, and pnpm.
- GUI applications on desktop machines from `Brewfile` or winget. Linux GUI
  installs currently include Alacritty.
- Shell plugins, tmux plugins, GitHub CLI extensions, Claude Code, rtk, and
  editor configurations.

## Layout

| Path | Purpose |
| --- | --- |
| `home/` | Files linked or copied into `$HOME` |
| `install.sh` | macOS/Linux/WSL installer and phase runner |
| `install.ps1` | Windows installer |
| `Brewfile` | macOS formulae and desktop casks |
| `home/.config/mise/config.toml` | Cross-platform tool inventory |
| `home/.config/vscode/` | Shared VS Code settings, keybindings, and extensions |
| `home/.config/nvim/` | LazyVim/Neovim configuration |
| `home/.config/{alacritty,wezterm,ghostty}/` | Terminal configuration |
| `home/.agents/skills/` | Skills linked into Claude Code and OpenCode |

Shell startup files are thin loaders. `.profile`, `.bashrc`, and `.zshrc`
source the sorted `~/.config/sh/*.sh` files, while zsh-only behavior lives in
`~/.config/zsh/*.zsh`.

## VS Code

The root configuration is shared across VS Code profiles and includes the
GitHub Dark theme, VSCodeVim mappings, editor behavior, language tooling, and
extensions for C/C++, Java, Python, Rust, shell, SQL, and web development.
The installer links the default settings and installs extensions additively.
It also supports optional `home/.config/vscode/profiles/<name>/` directories;
profile settings are merged over the shared configuration.

Run only this phase after installing VS Code:

```sh
./install.sh --only=vscode
```

## Local Overrides

Machine-specific files are intentionally untracked:

- `~/.config/sh/local.sh` for environment variables, proxies, and aliases.
- `~/.config/mise/conf.d/*.toml` for extra mise tools.
- `~/.config/wezterm/machine.lua` for fonts and private SSH domains.
- `~/.config/alacritty/machine.toml` for per-machine terminal settings.
- `~/.gitconfig.local` for Git settings not set by the tracked config.

The installer does not remove packages when they leave the inventory, and
extensions are installed additively. Remove those manually when required.

## Development Checks

From the repository root:

```sh
bash -n install.sh
bash -n home/.bashrc home/.bash_profile home/.profile home/.config/sh/*.sh home/.config/tmux/*.sh
zsh -n home/.zshrc home/.config/zsh/*.zsh
./install.sh --dry-run --headless
```

The dry run is safe: it reports package, link, and tool actions without
modifying `$HOME` or running installers.
