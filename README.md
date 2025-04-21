# Dotfiles

These are my personal dotfiles.

**Warning**: Use these files at your own risk! I do not take much care into safely backing existing files up, and I frequently make breaking changes here.

## Install

### Unix-like Operating Systems

Ensure you are using bash or zsh shell.

### Using install script

An install script is provided and can be downloaded and run using curl or wget command:

```bash
curl -o- https://raw.githubusercontent.com/bdsilver89/dotfiles/master/install.sh | bash
```

```bash
wget -qO- https://raw.githubusercontent.com/bdsilver89/dotfiles/master/install.sh | bash
```


### Using Git

1. `git clone http://github.com/bdsilver89/dotfiles.git $HOME/dotfiles`
2. `cd $HOME/dotfiles && ./bootstrap.sh`

### Windows

Powershell is the only supported shell for Windows.

1. `git clone http://github.com/bdsilver89/dotfiles.git $HOME/dotfiles`
2. `cd $HOME/dotfiles && ./bootstrap.ps1`

## Personal Development Environment (PDE) Overview

### Package Manager

- [Homebrew](https://brew.sh/)
- [asdf](https://asdf-vm.com/)

### Terminal

- [Alacritty](https://alacritty.org/)
- [WezTerm](https://wezfurlong.org/wezterm/index.html)
- [tmux](https://github.com/tmux/tmux)

### Shell

- [Oh My Zsh](https://ohmyz.sh/)
- [Starship](https://starship.rs/)

### Editor

- [Neovim](https://neovim.io/) and associated Lua configuration

### Language Specific Support

#### C/C++

- [CMake](https://cmake.org)
- [vcpkg](https://vcpkg.io/en/)
- [conan](https://conan.io)

#### Rust

TBD

#### Python

- [pyenv](https://github.com/pyenv/pyenv)

#### Node.JS

- [nvm](https://github.com/nvm-sh/nvm)
