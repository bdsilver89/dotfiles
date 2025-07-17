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
  if [ "$rc" -ne 0 ]; then
    log_err "Aborting - command failed with rc=$rc - $msg"
    exit "$rc"
  else
    log_err "Aborting - $msg"
    exit "$rc"
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
    echo "$name"
  fi
}

platform() {
  if [ -f /etc/debian_version ]; then
    echo debian
  elif [ -f /etc/os-release ]; then
    local id=$(grep -E ^ID= /etc/os-release | sed 's/.*=//; s/"//g')
    local version=$(grep -E ^VERSION_ID= /etc/os-release | sed 's/.*=//; s/"//g' | cut -d. -f1)
    echo "$id""$version"
  elif [[ $(os) == "darwin" ]]; then
    local id="macos"
    local version=$(sw_vers | grep -E ^ProductVersion | sed 's/.*://; s/ //g' | cut -d. -f1)
    echo "$id""$version"
  else
    echo win64
  fi
}

is_windows() {
  [[ "$(platform)" == win* ]]
}

is_wsl() {
  [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSL_INTEROP:-}" ]]
}

is_linux() {
  [[ "$(uname -s)" == "Linux" ]]
}

is_debian() {
  [[ "$(platform)" == "debian" ]]
}

is_ubuntu() {
  [[ -f /etc/lsb-release ]] || [[ -d /etc/lsb-release.d ]]
}

is_rhel() {
  [[ -f /etc/redhat-release ]]
}

is_darwin() {
  [[ "$(uname -s)" == "Darwin" ]]
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

      local current_src="$(readlink "$dst")"
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
  for src in $(find "${input}" -mindepth "$mindepth" -maxdepth "$maxdepth"); do
    basename="$(basename "${src}")"
    if [ "${basename}" != ".DS_Store" ]; then
      dst="${output}/$(basename "${src}")"
      link_file "$src" "$dst"
    fi
  done
}

git_clone() {
  local repo="$1"
  local dir="$2"

  if [ ! -d "$dir" ]; then
    info "Cloning $repo to $dir"
    git clone "$repo" "$dir" || log_and_die "Failed to clone $repo"
    success "Cloned $repo"
  else
    info "Directory $dir already exists, skipping clone"
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

  pushd "$dir" >/dev/null || exit
  curl -sL "${baseurl}/releases/download/${branch}/${tarfile}" >"${tarfile}"
  tar -xzf ./"${tarfile}"
  rm ./"${tarfile}"
  popd >/dev/null || exit
}

update() {
  title "Updating dotfiles"
  git pull origin main
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
  link_files_in_dir "${DOTFILES_DIR}/profile.d" "$HOME/.profile.d"
  link_files_in_dir "${DOTFILES_DIR}/config" "$HOME/.config"
  link_files_in_dir "${DOTFILES_DIR}/bin" "$HOME/.local/bin"
}

install_packages() {
  local packages=("$@")

  if [ ${#packages[@]} -eq 0 ]; then
    warning "No packages specified for installation"
    return 0
  fi

  info "Installing: ${packages[*]}"

  if is_debian || is_ubuntu; then
    # Update package cache first
    sudo apt update || log_and_die "Failed to update package cache"
    sudo apt install -y "${packages[@]}" || log_and_die "Failed to install packages: ${packages[*]}"
    success "Installed apt packages: ${packages[*]}"
  elif is_rhel; then
    if [ -x "$(command -v dnf)" ]; then
      sudo dnf install -y "${packages[@]}" || log_and_die "Failed to install packages: ${packages[*]}"
      success "Installed dnf packages: ${packages[*]}"
    else
      sudo yum install -y "${packages[@]}" || log_and_die "Failed to install packages: ${packages[*]}"
      success "Installed yum packages: ${packages[*]}"
    fi
  else
    log_warn "Could not figure out which package manager to use for platform: $(platform)"
    return 1
  fi
}

# Check if packages are available before attempting installation
check_package_availability() {
  local packages=("$@")
  local available_packages=()
  local unavailable_packages=()

  if is_debian || is_ubuntu; then
    for package in "${packages[@]}"; do
      if apt-cache show "$package" >/dev/null 2>&1; then
        available_packages+=("$package")
      else
        unavailable_packages+=("$package")
      fi
    done
  elif is_rhel; then
    for package in "${packages[@]}"; do
      if dnf info "$package" >/dev/null 2>&1 || yum info "$package" >/dev/null 2>&1; then
        available_packages+=("$package")
      else
        unavailable_packages+=("$package")
      fi
    done
  else
    # For other systems, assume all packages are available
    available_packages=("${packages[@]}")
  fi

  if [ ${#unavailable_packages[@]} -gt 0 ]; then
    warning "Unavailable packages (will be skipped): ${unavailable_packages[*]}"
  fi

  echo "${available_packages[@]}"
}

setup_apt_packages() {
  local packages=(
    autoconf
    automake
    bat
    build-essential
    ccache
    clang
    clang-format
    cmake
    gcc
    gdb
    libtool
    ninja-build
    pkg-config
    rpm
    tmux
    unzip
    zip
  )

  # Check availability and install only available packages
  local available_packages
  available_packages=($(check_package_availability "${packages[@]}"))

  if [ ${#available_packages[@]} -gt 0 ]; then
    install_packages "${available_packages[@]}"
  else
    warning "No packages available for installation"
  fi
}

setup_dnf_packages() {
  local packages=(
    autoconf
    automake
    ccache
    clang
    clang-tools-extra
    cmake
    gcc
    gcc-c++
    gdb
    libtool
    make
    neovim
    ninja-build
    python3
    python3-pip
    tmux
    vim
  )

  # Check availability and install only available packages
  local available_packages
  available_packages=($(check_package_availability "${packages[@]}"))

  if [ ${#available_packages[@]} -gt 0 ]; then
    install_packages "${available_packages[@]}"
  else
    warning "No packages available for installation"
  fi
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
    info "Installing tmux plugin manager (tpm)"
    git clone --depth 1 "https://github.com/tmux-plugins/tpm" "$tpm"
    success "Installed tpm"
  else
    info "tmux plugin manager already installed, skipping"
  fi
}

setup_neovim() {
  title "Setting up Neovim"

  if [ -d /tmp/neovim ]; then
    rm -rf /tmp/neovim
  fi

  git clone "https://github.com/neovim/neovim" "/tmp/neovim"
  cd /tmp/neovim || exit
  git checkout stable

  make CMAKE_BUILD_TYPE=Release -j
  sudo make CMAKE_BUILD_TYPE=Release install
}

setup_asdf_tool() {
  local name="$1"
  local version="$2"

  if test ! "$(command -v asdf)"; then
    error "asdf command not found"
    return 1
  fi

  info "Adding $name (version $version) with asdf"
  asdf plugin add "$name" 2>/dev/null || true # plugin might already exist
  asdf install "$name" "$version"
  asdf set -u "$name" "$version"
}

setup_asdf() {
  title "Setting up asdf"

  local target_version="v0.18.0"

  # Check if asdf is already installed and get version
  if command -v asdf >/dev/null 2>&1; then
    local current_version=$(asdf version 2>/dev/null | awk '{print $1}' | sed 's/^v//')
    local target_version_clean=$(echo "$target_version" | sed 's/^v//')

    info "asdf currently installed: v$current_version"
    info "Target version: $target_version"

    if [ "$current_version" = "$target_version_clean" ]; then
      info "asdf is already up to date, skipping download"
      # Skip to tool installation
    else
      info "asdf version mismatch, updating to $target_version"
      # Remove old version and install new one
      rm -rf "${HOME}/.local/bin/asdf"
    fi
  else
    info "asdf not found, installing $target_version"
  fi

  # Install asdf if not present or version mismatch
  if ! command -v asdf >/dev/null 2>&1 || [ ! -f "${HOME}/.local/bin/asdf" ]; then
    local suffix=""
    if is_linux; then
      suffix="-linux-amd64"
    elif is_darwin; then
      suffix="-darwin-arm64"
    fi
    github_download_release "asdf-vm" "asdf" "$target_version" "$suffix" "${HOME}/.local/bin"

    # Source asdf for current session
    export PATH="${HOME}/.local/bin:$PATH"
  fi

  # Install tools
  local tools=(
    "bat latest"
    "eza latest"
    "fd latest"
    "fzf latest"
    "jq latest"
    "lazygit latest"
    "ripgrep latest"
    "zoxide latest"
  )

  for tool in "${tools[@]}"; do
    local name=$(echo "$tool" | cut -d' ' -f1)
    local version=$(echo "$tool" | cut -d' ' -f2)
    setup_asdf_tool "$name" "$version"
  done
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

    mkdir -p "$HOME"/.local/share/fonts/JetBrainsMonoNerd
    tar -xJkf /tmp/JetBrainsMono.tar.xz -C "$HOME"/.local/share/fonts/JetBrainsMonoNerd

    fc-cache
  fi
}

# Dry run mode
DRY_RUN=${DRY_RUN:-false}

dry_run_execute() {
  if [ "$DRY_RUN" = "true" ]; then
    log_info "[DRY RUN] Would execute: $*"
  else
    "$@"
  fi
}

# Progress tracking
TOTAL_STEPS=0
CURRENT_STEP=0

progress() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  log_info "[$CURRENT_STEP/$TOTAL_STEPS] $*"
}

set_total_steps() {
  TOTAL_STEPS="$1"
}

main() {
  local run_all=false
  local steps_to_run=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --dry-run)
      DRY_RUN=true
      info "Running in dry-run mode"
      ;;
    --update)
      steps_to_run+=("update")
      ;;
    --fonts)
      steps_to_run+=("setup_fonts")
      ;;
    --hyprland)
      steps_to_run+=("setup_hyprland")
      ;;
    --mac)
      steps_to_run+=("setup_homebrew")
      ;;
    --linux)
      steps_to_run+=("setup_linux")
      ;;
    --symlinks)
      steps_to_run+=("setup_symlinks")
      ;;
    --neovim)
      steps_to_run+=("setup_neovim")
      ;;
    --asdf)
      steps_to_run+=("setup_asdf")
      ;;
    --zsh-omz)
      steps_to_run+=("setup_zsh_omz")
      ;;
    --zsh-zinit)
      steps_to_run+=("setup_zsh_zinit")
      ;;
    --tmux)
      steps_to_run+=("setup_tmux")
      ;;
    --all)
      run_all=true
      steps_to_run=(
        "update"
        "setup_symlinks"
        "setup_homebrew"
        "setup_linux"
        "setup_tmux"
        "setup_asdf"
        "setup_zsh_zinit"
      )
      ;;
    --help)
      echo "
Usage: $(basename "$0") [OPTIONS]

OPTIONS:
--all       Perform all of the configuration steps
--dry-run   Show what would be done without making changes
--fonts     Install fonts
--hyprland  Install and configure hyprland desktop environment
--mac       Install brew and brew utilities
--linux     Install utilities using system package manager
--symlinks  Configure dotfiles from this repo in system locations
--tmux      Install and configure tmux with tpm plugins
--neovim    Install and configure neovim
--asdf      Install and configure asdf package manager
--zsh-omz   Install zsh and plugins using oh-my-zsh
--zsh-zinit Install zsh and plugins using zinit
--update    Update local dotfile repository
--help      Show this help message
"
      exit 0
      ;;
    *)
      error "Unknown option '$1'. Use --help for usage information."
      exit 1
      ;;
    esac
    shift
  done

  # Set total steps for progress tracking
  set_total_steps ${#steps_to_run[@]}

  # Execute requested steps
  for step in "${steps_to_run[@]}"; do
    if [ "$DRY_RUN" = "true" ]; then
      progress "Would run: $step"
    else
      progress "Running: $step"
      dry_run_execute "$step"
    fi
  done

  if [ ${#steps_to_run[@]} -eq 0 ]; then
    warning "No operations specified. Use --help for usage information."
    exit 1
  fi

  echo -e
  success "Done"
  exit 0
}

main "$@"
