#!/usr/bin/env bash

DOTFILES_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# use some of the submodules bundled with dotfiles
source $DOTFILES_DIR/bash/utils.sh
source $DOTFILES_DIR/bash/logging.sh

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
	for src in $(find "${DOTFILES_DIR}/config" -mindepth 1 -maxdepth 1); do
		basename="$(basename ${src})"
		if [ ${basename} != ".DS_Store" ]; then
			dst="$HOME/.config/$(basename ${src})"
			link_file "$src" "$dst"
		fi
	done

	# link scripts
	for src in $(find "${DOTFILES_DIR}/bin" -mindepth 1 -maxdepth 1); do
		dst="$HOME/.local/bin/$(basename ${src})"
		link_file "$src" "$dst"
	done
}

setup_apt_packages() {
	local packages=(
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
		if is_debian; then
			setup_apt_packages
		fi
	fi
}

setup_zsh() {
	title "Setting up zsh"

	if [ ! -d "${HOME}/.oh-my-zsh" ]; then
		git clone "https://github.com/ohmyzsh/ohmyzsh" "${HOME}/.oh-my-zsh"

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
