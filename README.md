# Dotfiles

These are my personal dotfiles for a comprehensive development environment across macOS and Linux systems.

**Warning**: Use these files at your own risk! I do not take much care into safely backing existing files up, and I frequently make breaking changes here.

## Quick Start

### Unix-like Operating Systems

Ensure you are using bash or zsh shell.

#### Using install script

An install script is provided and can be downloaded and run using curl or wget command:

```bash
curl -o- https://raw.githubusercontent.com/bdsilver89/dotfiles/main/install.sh | bash
```

```bash
wget -qO- https://raw.githubusercontent.com/bdsilver89/dotfiles/main/install.sh | bash
```

#### Using Git

1. `git clone https://github.com/bdsilver89/dotfiles.git $HOME/dotfiles`
2. `cd $HOME/dotfiles && ./bootstrap.sh --all`

### Windows

Powershell is the only supported shell for Windows.

1. `git clone https://github.com/bdsilver89/dotfiles.git $HOME/dotfiles`
2. `cd $HOME/dotfiles && ./bootstrap.ps1`

## Bootstrap Options

The `bootstrap.sh` script supports granular installation with the following options:

| Option | Description |
|--------|-------------|
| `--all` | Perform all configuration steps (recommended for first-time setup) |
| `--dry-run` | Show what would be done without making changes |
| `--update` | Update the local dotfiles repository |
| `--symlinks` | Create symlinks from dotfiles to system locations |
| `--mac` | Install Homebrew and packages from Brewfile |
| `--linux` | Install packages using system package manager (apt/dnf) |
| `--asdf` | Install asdf and CLI tools (bat, eza, fd, fzf, jq, lazygit, ripgrep, zoxide) |
| `--tmux` | Install tmux plugin manager (tpm) and plugins |
| `--zsh-omz` | Install oh-my-zsh and plugins |
| `--zsh-zinit` | Install zinit plugin manager |
| `--neovim` | Build and install Neovim from source (stable branch) |
| `--fonts` | Install JetBrains Mono Nerd Font |
| `--hyprland` | Install Hyprland desktop environment (Linux only) |

### Example Usage

```bash
# First time setup (macOS)
./bootstrap.sh --all

# Update specific components
./bootstrap.sh --symlinks --asdf

# Dry run to see what would change
./bootstrap.sh --dry-run --all
```

## Personal Development Environment (PDE) Overview

### Package Managers

- **[Homebrew](https://brew.sh/)** - macOS package manager
- **[asdf](https://asdf-vm.com/)** - Multi-language version manager for CLI tools

### Terminal Emulators

- **[Alacritty](https://alacritty.org/)** - GPU-accelerated terminal emulator
- **[WezTerm](https://wezfurlong.org/wezterm/)** - GPU-accelerated cross-platform terminal
- **[Ghostty](https://ghostty.org/)** - Fast, native terminal emulator
- **[tmux](https://github.com/tmux/tmux)** - Terminal multiplexer with custom configuration

### Shell Configuration

- **[Zsh](https://www.zsh.org/)** - Primary shell
- **[Oh My Zsh](https://ohmyz.sh/)** - Zsh framework with plugins:
  - zsh-autosuggestions
  - zsh-completions
  - zsh-syntax-highlighting
  - fzf-tab
  - powerlevel10k theme
- **[zinit](https://github.com/zdharma-continuum/zinit)** - Alternative plugin manager
- **[Starship](https://starship.rs/)** - Cross-shell prompt

### Window Management

#### macOS
- **[yabai](https://github.com/koekeishiya/yabai)** - Tiling window manager
- **[skhd](https://github.com/koekeishiya/skhd)** - Hotkey daemon

#### Linux
- **[Hyprland](https://hyprland.org/)** - Dynamic tiling Wayland compositor
- **[Waybar](https://github.com/Alexays/Waybar)** - Status bar
- **[SwayNC](https://github.com/ErikReider/SwayNotificationCenter)** - Notification center
- **[wlogout](https://github.com/ArtsyMacaw/wlogout)** - Logout menu

### Editors and IDEs

- **[Neovim](https://neovim.io/)** - Primary editor with Lua configuration
- **[Zed](https://zed.dev/)** - Modern collaborative editor
- **[VSCode](https://code.visualstudio.com/)** - Alternative editor

### CLI Tools (Managed via asdf)

- **[bat](https://github.com/sharkdp/bat)** - Cat clone with syntax highlighting
- **[eza](https://github.com/eza-community/eza)** - Modern replacement for ls
- **[fd](https://github.com/sharkdp/fd)** - Simple, fast alternative to find
- **[fzf](https://github.com/junegunn/fzf)** - Fuzzy finder
- **[jq](https://github.com/jqlang/jq)** - JSON processor
- **[lazygit](https://github.com/jesseduffield/lazygit)** - Terminal UI for git
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** - Fast search tool
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** - Smarter cd command

### Fonts

- **JetBrains Mono Nerd Font** - Primary font with icons and ligatures

### Language Development Support

#### C/C++

- **[CMake](https://cmake.org)** - Build system
- **[vcpkg](https://vcpkg.io/)** - C/C++ package manager
- **[conan](https://conan.io)** - C/C++ package manager
- Compiler toolchains: GCC, Clang
- Tools: ccache, clang-format, gdb

#### Rust

Managed via asdf or rustup

#### Python

- **[pyenv](https://github.com/pyenv/pyenv)** - Python version management
- Development tools via system packages and pip

#### Node.js

Managed via asdf version manager

## Repository Structure

```
dotfiles/
├── config/           # Application configurations (symlinked to ~/.config/)
│   ├── alacritty/
│   ├── hypr/
│   ├── nvim/
│   ├── starship.toml
│   ├── wezterm/
│   └── ...
├── bin/              # User scripts (symlinked to ~/.local/bin/)
├── profile.d/        # Shell profile snippets
├── zsh/              # Zsh configuration
├── tmux/             # Tmux configuration
├── git/              # Git configuration
├── bootstrap.sh      # Main setup script (Unix/Linux/macOS)
├── bootstrap.ps1     # Setup script (Windows)
├── install.sh        # Quick install script
└── Brewfile          # Homebrew package definitions
```

## Customization

Most configurations can be customized through their respective config files in the `config/` directory. After making changes:

1. Edit the configuration files
2. Re-run `./bootstrap.sh --symlinks` if needed
3. Reload your shell or restart the application

## Troubleshooting

- If symlinks fail, check for existing files and use `--dry-run` first
- For permission issues on Linux, ensure sudo access is available
- macOS users may need to disable System Integrity Protection (SIP) for yabai
- Run individual bootstrap steps to isolate issues

## Contributing

These are personal dotfiles, but feel free to fork and adapt to your needs. If you find bugs or have suggestions, issues and PRs are welcome.

## License

MIT License - use at your own risk.
