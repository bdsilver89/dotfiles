#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

  dotfiles_has() {
    type "$1" >/dev/null 2>&1
  }

  dotfiles_echo() {
    command printf %s\\n "$*" 2>/dev/null
  }

  dotfiles_default_install_dir() {
    printf %s "${HOME}/dotfiles"
  }

  dotfiles_install_dir() {
    if [ -n "${DOTFILES_DIR}" ]; then
      printf %s "${DOTFILES_DIR}"
    else
      dotfiles_default_install_dir
    fi
  }

  dotfiles_source() {
    local DOTFILES_GITHUB_REPO
    DOTFILES_GITHUB_REPO="${DOTFILES_INSTALL_GITHUB_REPO:-bdsilver89/dotfiles}"
    if [ "${DOTFILES_GITHUB_REPO}" != "bdsilver89/dotfiles" ]; then
      { dotfiles_echo >&2 "$(cat)"; } <<EOF
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE REPO IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

The default repository for this install is
\`bdsilver89/dotfiles\`, but the environment variables
\`\$DOTFILES_INSTALL_GITHUB_REPO\` is currently set to
\`${DOTFILES_GITHUB_REPO}\`.

If this is not intentional, interrupt this installation and 
verify your environment variable.
EOF
    fi

    echo "https://github.com/${DOTFILES_GITHUB_REPO}.git"
  }

  dotfiles_install_from_git() {
    local INSTALL_DIR
    INSTALL_DIR="$(dotfiles_install_dir)"

    if [ -d "$INSTALL_DIR/.git" ]; then
      dotfiles_echo "=> dotfiles are already installed in $INSTALL_DIR, trying to update using git"
      command printf "\r=> "
      fetch_error="Failed to update dotfiles, run 'git fetch' in $INSTALL_DIR yourself"
    else
      fetch_error="Failed to fetch origin"
      dotfiles_echo "=> Downloading dotfiles from git to '$INSTALL_DIR'"
      command printf "\r=> "
      mkdir -p "${INSTALL_DIR}"
      if [ "$(ls -A "${INSTALL_DIR}")" ]; then
        command git init "${INSTALL_DIR}" || {
          dotfiles_echo >&2 "Failed to initialize dotfiles repo"
          exit 2
        }
        command git --git-dir="${INSTALL_DIR}/.git" remote add origin "$(dotfiles_source)" 2>/dev/null ||
          command git --git-dir="${INSTALL_DIR}/.git" remote set-url origin "$(dotfiles_source)" || {
          dotfiles_echo >&2 "Failed to add remote 'origin' (or set the URL)"
          exit 2
        }
      else
        command git clone "$(dotfiles_source)" "${INSTALL_DIR}" || {
          dotfiles_echo >&2 "Failed to clone dotfiles repo"
          exit 2
        }
      fi
    fi

    if ! command git --git-dir="$INSTALL_DIR/.git" --work-tree="$INSTALL_DIR" fetch origin main 2>/dev/null; then
      dotfiles_echo >&2 "$fetch_error"
      exit 1
    fi

    return
  }

  dotfiles_do_install() {
    if dotfiles_has git; then
      dotfiles_install_from_git
    else
      dotfiles_echo >&2 "You need git, curl, or wget to install these dotfiles"
      exit 1
    fi
  }

  dotfiles_do_install

} # this ensures the entire script is downloaded #
