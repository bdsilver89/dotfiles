#!/usr/bin/env bash

DOTFILES_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
	echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
	echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
	echo -e "${COLOR_RED}$1${COLOR_NONE}"
	exit 1
}

warning() {
	echo -e "${COLOR_YELLOW}$1${COLOR_NONE}"
}

info() {
	echo -e "${COLOR_BLUE}$1${COLOR_NONE}"
}

success() {
	echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
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
		info "Overwriting $dst"
	fi

	if [ "$backup" == "true" ]; then
		mv "$dst" "${dst}.backup"
		info "Backing up $dst"
	fi

	if [ "$skip" == "true" ]; then
		success "Skipping $dst"
	fi

	if [ "$skip" != "true" ]; then
		ln -s "$src" "$dst"
		success "Linked $src to $dst"
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

setup_homebrew() {
	if [[ "$(uname)" == "Darwin" ]]; then
		title "Setting up homebrew"
		if test ! "$(command -v brew)"; then
			info "Homebrew not installed. Installing now"
			curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash --login
		fi

		info "Installing brew dependencies"
		brew bundle
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
	symlinks)
		setup_symlinks
		;;
	tmux)
		setup_tmux
		;;
	all)
		setup_git
		update
		setup_symlinks
		setup_homebrew
		setup_tmux
		;;
	*)
		echo -e $"\nUsage: $(basename "$0") {all|git|mac|symlinks|tmux|update}\n"
		exit 1
		;;
	esac

	echo -e
	success "Done"
	exit 0
}

main "$*"
