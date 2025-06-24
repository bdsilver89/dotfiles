#!/usr/bin/env bash

DOTFILES_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# ----------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------
LOG_VERBOSITY=${LOG_VERBOSITY:-2}
LOG_DATE=${LOG_DATE:-true}
LOG_CONSOLE=${LOG_CONSOLE:-false}
LOG_FORCE_COLORS=${LOG_FORCE_COLORS:-false}

LOG_COLOR_DEFAULT="\e[0;39m"
LOG_COLOR_GREY="\e[1;30m"
LOG_COLOR_RED="\e[1;31m"
LOG_COLOR_GREEN="\e[1;32m"
LOG_COLOR_YELLOW="\e[1;33m"
LOG_COLOR_BLUE="\e[1;34m"
LOG_COLOR_PURPLE="\e[1;35m"
LOG_COLOR_CYAN="\e[1;36m"

log() {
  if [ -t 1 ]; then
    printf "${@}"
    printf "\n"
  fi
}

log_err() {
  log "${LOG_COLOR_RED}$*${LOG_COLOR_DEFAULT}"
}

log_warn() {
  log "${LOG_COLOR_YELLOW}$*${LOG_COLOR_DEFAULT}"
}

log_info() {
  log "${LOG_COLOR_GREEN}$*${LOG_COLOR_DEFAULT}"
}

log_status() {
  log "${LOG_COLOR_BLUE}$*${LOG_COLOR_DEFAULT}"
}

log_success() {
  log "${LOG_COLOR_GREEN}\nSuccess${LOG_COLOR_DEFAULT}!"
}

log_failure() {
  log "${LOG_COLOR_RED}\nFailure${LOG_COLOR_DEFAULT}!"
}

log_and_die() {
  local rc=$?
  local msg=${*:-"unknown error"}
  if [ $rc -ne 0 ]; then
    log_err "Aborting - command failed with rc=$rc - $msg"
    exit $rc
  else
    log_err "Aborting - $msg"
    exit $rc
  fi
}

title() {
  log "\n${LOG_COLOR_PURPLE}$*${LOG_COLOR_DEFAULT}"
  log "${LOG_COLOR_GREY}==============================${LOG_COLOR_DEFAULT}\n"
}

error() {
  log_err "$*"
  exit 1
}

warning() {
  log_warn "$*"
}

info() {
  log "$*"
}

status() {
  log_status "$*"
}

success() {
  log_info "$*"
}

# -----------------------------------------------------------------------------
# OS/platform
# -----------------------------------------------------------------------------
os() {
  local name=$(uname -s)
  if [[ $name =~ MINGW ]] || [[ $os =~ MSYS ]]; then
    echo windows
  elif [[ $name =~ FreeBSD ]]; then
    echo bsd
  elif [[ $name =~ Darwin ]]; then
    echo darwin
  else
    echo $name
  fi
}

platform() {
  if [ -f /etc/debian_version ]; then
    echo debian
  elif [ -f /etc/os-release ]; then
    local id=$(grep -E ^ID= /etc/os-release | sed 's/.*=//; s/"//g')
    local version=$(grep -E ^VERSION_ID= /etc/os-release | sed 's/.*=//; s/"//g' | cut -d. -f1)
    echo $id$version
  elif [[ $(os) == "darwin" ]]; then
    local id="macos"
    local version=$(sw_vers | grep -E ^ProductVersion | sed 's/.*://; s/ //g' | cut -d. -f1)
    echo $id$version
  else
    echo win64
  fi
}

is_windows() {
  [ ${$(platform):0:3} = win ]
}

is_wsl() {
  [[ -n $WSL_DISTO_NAME ]]
}

is_linux() {
  [ $(os) = Linux ]
}

is_debian() {
  [ $(platform) = debian ]
}

is_ubuntu() {
  [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]
}

is_rhel() {
  [ -f /etc/redhat-release ]
}

is_darwin() {
  [ $(os) = darwin ]
}

# -----------------------------------------------------------------------------
# date/time utils
# -----------------------------------------------------------------------------
isodate() {
  date +%Y-%m-%dT%H-%M:%Sz
}

isodate_utc() {
  date -u +%Y-%m-%dT%H-%M:%SZ
}

unixstamp() {
  date +%s
}

link_file() {
  local src=$1
  local dst=$2

  local skip=
  local overwrite=
  local backup=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then

      local current_src="$(readlink $dst)"
      if [ "$current_src" == "$src" ]; then
        skip=true

      else
        warning "File already exists: $dst ($(basename "$src")), what should be done? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action
        echo -e ""

        case "$action" in
        s) skip=true ;;
        o) overwrite=true ;;
        b) backup=true ;;
        S) skip_all=true ;;
        O) overwrite_all=true ;;
        B) backup_all=true ;;
        *) ;;
        esac
      fi
    fi
  fi

  overwrite=${overwrite:-$overwrite_all}
  backup=${backup:-$backup_all}
  skip=${skip:-$skip_all}

  if [ "$overwrite" == "true" ]; then
    rm -rf "$dst"
    status "Overwriting $dst"
  fi

  if [ "$backup" == "true" ]; then
    mv "$dst" "${dst}.backup"
    status "Backing up $dst"
  fi

  if [ "$skip" == "true" ]; then
    log "Skipping $dst"
  fi

  if [ "$skip" != "true" ]; then
    ln -s "$src" "$dst"
    status "Linked $src to $dst"
  fi
}

link_files_in_dir() {
  local input=$1
  local output=$2
  local mindepth=${3:-1}
  local maxdepth=${4:-1}

  if [ ! -d "${output}" ]; then
    mkdir -p "${output}"
  fi
  for src in $(find ${input} -mindepth $mindepth -maxdepth $maxdepth); do
    basename="$(basename ${src})"
    if [ ${basename} != ".DS_Store" ]; then
      dst="${output}/$(basename ${src})"
      link_file "$src" "$dst"
    fi
  done
}

git_clone() {
  local repo="$1"
  local dir="$2"

  if [ ! -d "$dir" ]; then
    git clone "$repo" "$dir"
  fi
}

github_download_release() {
  local user="$1"
  local repo="$2"
  local branch="$3"
  local suffix="$4"
  local dir="$5"

  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi

  local baseurl="https://github.com/${user}/${repo}"
  local tarfile="${repo}-${branch}${suffix}.tar.gz"

  info "Downloading $tarfile from $baseurl"

  pushd $dir >  /dev/null
  curl -sL "${baseurl}/releases/download/${branch}/${tarfile}" > "${tarfile}"
  tar -xzf ./${tarfile}
  rm ./${tarfile}
  popd > /dev/null
}

update() {
  title "Updating dotfiles"
  git pull origin main
}

setup_git() {
  title "Setting up Git"
}

setup_symlinks() {
  title "Setting up symlinks"

  # global flags for conflict behavior, handled inside all calls to link_file
  local overwrite_all=false
  local skip_all=false
  local backup_all=false

  # link symlinked home files
  for src in $(find -H "$DOTFILES_DIR" -maxdepth 3 -name '*.symlink'); do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done

  link_files_in_dir "${DOTFILES_DIR}/bashrc.d" "$HOME/.bashrc.d"
  link_files_in_dir "${DOTFILES_DIR}/zshrc.d" "$HOME/.zshrc.d"
  link_files_in_dir "${DOTFILES_DIR}/config" "$HOME/.config"
  link_files_in_dir "${DOTFILES_DIR}/bin" "$HOME/.local/bin"
}

install_packages() {
  local p="$@"
  info "Installing: $p"
  if is_debian || is_ubuntu; then
    sudo apt install -y $p || log_and_die "Failed to install packages"
      success "Installed apt packages"
  elif is_rhel; then
    if [ -x "$(command -v dnf)" ]; then
      sudo dnf install -y $p || log_and_die "Failed to install packages"
      success "Installed dnf packages"
    else
      sudo yum install -y $p || log_and_die "Failed to install packages"
      success "Installed yum packages"
    fi
  else
    log_warn "Could not figure out which package manager to use for platform: $(platform)"
  fi
}

setup_apt_packages() {
  local packages=(
    bat
    cmake
    gcc
    build-essential
    clang
    clang-format
    ninja-build
    ccache
    automake
    autoconf
    libtool
    pkg-config
    rpm
    zip
    unzip
    gdb
    # jq
    tmux
    # zoxide
    # fzf
    # ripgrep
    # fd-find
    # eza is not available on ubuntu
  )

  install_packages ${packages[@]}
}

setup_dnf_packages() {
  local packages=(
    autoconf
    automake
    # bat
    ccache
    clang
    clang-tools-extra
    cmake
    # eza
    # fd-find
    # fzf
    gcc
    gcc-c++
    gdb
    # jq
    libtool
    make
    neovim
    ninja-build
    python3
    python3-pip
    # pkg-config
    # rpm
    # zip
    # unzip
    # ripgrep
    tmux
    vim
    # zoxide
  )

  install_packages ${packages[@]}
}

setup_homebrew() {
  if is_darwin; then
    title "Setting up Darwin settings"
    if test ! "$(command -v brew)"; then
      info "Homebrew not installed. Installing now"
      curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash --login
    fi

    info "Installing brew dependencies"
    brew bundle
  fi
}

setup_linux() {
  if is_linux; then
    title "Setting up Linux settings"
    if is_debian || is_ubuntu; then
      setup_apt_packages
    elif is_rhel && [ -x "$(command -v dnf)" ]; then
      setup_dnf_packages
    else
      log_warn "Could not figure out which package manager to use for platform: $(platform)"
    fi
  fi
}

setup_zsh_omz() {
  title "Setting up zsh (oh-my-zsh)"

  local omz="${HOME}/.oh-my-zsh"
  local omz_plugins="${omz}/custom/plugins"
  local omz_themes="${omz}/custom/themes"

  git_clone "https://github.com/ohmyzsh/ohmyzsh" "$omz"
  git_clone "https://github.com/zsh-users/zsh-autosuggestions" "${omz_plugins}/zsh-autosuggestions"
  git_clone "https://github.com/zsh-users/zsh-completions" "${omz_plugins}/zsh-completions"
  git_clone "https://github.com/zsh-users/zsh-syntax-highlighting" "${omz_plugins}/zsh-syntax-highlighting"
  git_clone "https://github.com/Aloxaf/fzf-tab" "${omz_plugins}/fzf-tab"
  git_clone "https://github.com/romkatv/powerlevel10k" "${omz_themes}/powerlevel10k"
}

setup_zsh_zinit() {
  title "Setting up zsh (zinit)"

  local zinit="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  git_clone "https://github.com/zdharma-continuum/zinit.git" "$zinit"
}

setup_tmux() {
  title "Setting up tmux"

  local tpm="${HOME}/.tmux/plugins/tpm"
  if [ ! -d "$tpm" ]; then
    git clone --depth 1 "https://github.com/tmux-plugins/tpm" "$tpm"
  fi
}

setup_asdf() {
  title "Setting up asdf"

  local suffix=""
  if is_linux; then
    suffix="-linux-amd64"
  elif is_darwin; then
    suffix="-darwin-arm64"
  fi
  github_download_release "asdf-vm" "asdf" "v0.16.7" "$suffix" "${HOME}/.local/bin"

  setup_asdf_tool() {
    local name="$1"
    local version="$2"

    if test ! "$(command -v asdf)"; then
      error "asdf command not found"
      return 1
    fi

    info "Adding $name (version $version) with asdf"
    asdf plugin add $name
    asdf install $name $version
    asdf set -u $name $version
  }

  setup_asdf_tool bat latest
  setup_asdf_tool eza latest
  setup_asdf_tool fd latest
  setup_asdf_tool fzf latest
  setup_asdf_tool jq latest
  setup_asdf_tool lazygit latest
  setup_asdf_tool ripgrep latest
  setup_asdf_tool zoxide latest
}

setup_hyprland() {
  # don't want to default install these for linux setup process
  # linux setup may be on a container, WSL, server, etc. which does not have a
  # desktop environment.
  # symlinking the config files is ok elsewhere but leave program installation here
  if is_linux; then
    title "Setting up hyprland"

    # fedora 42 does not yet have hyprpaper, hyprlock or hypridle
    # need to add this copr repo to get things working
    if [ "$(platform)" = "fedora42" ]; then
      info "Adding Fedora42 copr repository"
      sudo dnf copr enable -y "solopasha/hyprland" || log_and_die "Failed to setup hyprland copr"
    fi

    install_packages hyprland hypridle hyprlock waybar swaync wlogout pamixer pavucontrol blueman nmtui Thunar
  fi
}

setup_fonts() {
  if is_linux; then
    title "Setting up fonts"

    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    curl -o /tmp/JetBrainsMono.tar.xz -OL "$url"

    mkdir -p $HOME/.local/share/fonts/JetBrainsMonoNerd
    tar -xJkf /tmp/JetBrainsMono.tar.xz -C $HOME/.local/share/fonts/JetBrainsMonoNerd

    fc-cache
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --update)
      update
      ;;
    --fonts)
      setup_fonts
      ;;
    --hyprland)
      setup_hyprland
      ;;
    --git)
      setup_git
      ;;
    --mac)
      setup_homebrew
      ;;
    --linux)
      setup_linux
      ;;
    --symlinks)
      setup_symlinks
      ;;
    --asdf)
      setup_asdf
      ;;
    --zsh-omz)
      setup_zsh_omz
      ;;
    --zsh-zinit)
      setup_zsh_zinit
      ;;
    --tmux)
      setup_tmux
      ;;
    --all)
      setup_git
      update
      setup_symlinks
      setup_homebrew
      setup_linux
      setup_tmux
      setup_asdf
      # setup_zsh_omz
      setup_zsh_zinit
      ;;
    --help)
      echo "
Usage: $(basename "$0")

--all       Perform all of the configuration steps
--fonts     Install fonts
--hyprland  Installs and configures hyprland desktop environment
--git       Configures global git setup
--mac       Install brew and brew utilities
--linux     Installs utilities using system package manager (only apt for now)
--symlinks  Configures dotfiles from this repo in system locations
--tmux      Installs and configures tmux with tpm plugins
--asdf      Installs and configures asdf package manager
--zsh-omz   Installs zsh and plugins using oh-my-zsh
--zsh-zinit Installs zsh and plugins using zinit
--update    Update local dotfile repository
"
      exit 0
      ;;
    *)
      error "Unknown option '$1'"
      exit 1
      ;;
    esac
    shift
  done

  echo -e
  success "Done"
  exit 0
}

main "$@"
