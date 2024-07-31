#!/usr/bin/env bash

DOTFILES_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# ----------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------
LOG_VERBOSITY=${LOG_VERBOSITY:-2}
LOG_DATE=${LOG_DATE:-true}
LOG_CONSOLE=${LOG_CONSOLE:-false}
LOG_FORCE_COLORS=${LOG_FORCE_COLORS:-false}

LOG_BG=${1:-1}
LOG_COLOR_DEFAULT="\e[0;39m"
LOG_COLOR_GREY="\e[$BG;30m"
LOG_COLOR_RED="\e[$BG;31m"
LOG_COLOR_GREEN="\e[$BG;32m"
LOG_COLOR_YELLOW="\e[$BG;33m"
LOG_COLOR_BLUE="\e[$BG;34m"
LOG_COLOR_PURPLE="\e[$BG;35m"
LOG_COLOR_CYAN="\e[$BG;36m"

log() {
	if [ -t 1 ]; then
		printf "${@}"
		printf "\n"
	fi
}

log_err() {
	log "${LOG_COLOR_RED}$*${LOG_COLORDEFAULT}"
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
	log "${LOG_COLOR_GRAY}==============================${LOG_COLOR_DEFAULT}\n"
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
		local id=$(egrep ^ID= /etc/os-release | sed 's/.*=//; s/"//g')
		local version=$(egrep ^VERSION_ID= /etc/os-release | sed 's/.*=//; s/"//g' | cut -d. -f1)
		echo $id$version
	elif [[ $(os) == "darwin" ]]; then
		local id="macos"
		local version=$(sw_vers | egrep ^ProductVersion | sed 's/.*://; s/ //g' | cut -d. -f1)
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

update() {
	title "Updating"
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

	# link config files
	if [ ! -d "$HOME/.config" ]; then
		mkdir -p "$HOME/.config"
	fi
	for src in $(find "${DOTFILES_DIR}/config" -mindepth 1 -maxdepth 1); do
		basename="$(basename ${src})"
		if [ ${basename} != ".DS_Store" ]; then
			dst="$HOME/.config/$(basename ${src})"
			link_file "$src" "$dst"
		fi
	done

	# link scripts
	if [ ! -d "$HOME/.local/bin" ]; then
		mkdir -p "$HOME/.local/bin"
	fi
	for src in $(find "${DOTFILES_DIR}/bin" -mindepth 1 -maxdepth 1); do
		dst="$HOME/.local/bin/$(basename ${src})"
		link_file "$src" "$dst"
	done
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
		jq
		tmux
		zoxide
		fzf
		ripgrep
		fd-find
		exa # eza is not available on ubuntu
	)

	info "Installing apt packages"
	sudo apt install -y ${packages[@]} || log_and_die "Failed to install packages"
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
		fi
	fi
}

setup_zsh() {
	title "Setting up zsh"

	if [ ! -d "${HOME}/.oh-my-zsh" ]; then
		git clone "https://github.com/ohmyzsh/ohmyzsh" "${HOME}/.oh-my-zsh"
	fi

	if [ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
		git clone "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	fi

	if [ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-completions" ]; then
		git clone "https://github.com/zsh-users/zsh-completions" "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
	fi

	if [ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
		git clone "https://github.com/zsh-users/zsh-syntax-highlighting" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	fi

	if [ ! -d "${HOME}/.oh-my-zsh/custom/plugins/fzf-tab" ]; then
		git clone "https://github.com/Aloxaf/fzf-tab" "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"
	fi

	if [ ! -d "${HOME}/.oh-my-zsh/custom/thems/powerlevel10k" ]; then
		git clone --depth 1 "https://github.com/romkatv/powerlevel10k" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
	fi
}

setup_tmux() {
	title "Setting up tmux"

	if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
		git clone --depth 1 "https://github.com/tmux-plugins/tpm" "${HOME}/.tmux/plugins/tpm"
	fi
}

main() {
	case "$1" in
	update)
		update
		;;
	git)
		setup_git
		;;
	mac)
		setup_homebrew
		;;
	linux)
		setup_linux
		;;
	symlinks)
		setup_symlinks
		;;
	zsh)
		setup_zsh
		;;
	tmux)
		setup_tmux
		;;
	all)
		setup_git
		update
		setup_symlinks
		setup_homebrew
		setup_linux
		setup_tmux
		setup_zsh
		;;
	*)
		echo -e $"\nUsage: $(basename "$0") {all|git|mac|linux|symlinks|tmux|zsh|update}\n"
		exit 1
		;;
	esac

	echo -e
	success "Done"
	exit 0
}

main "$*"
