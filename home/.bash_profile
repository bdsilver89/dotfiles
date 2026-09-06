# bash reads only the FIRST of ~/.bash_profile, ~/.bash_login and ~/.profile
# that exists, unlike sh and dash which always read ~/.profile. Owning this file
# is what stops an installer-dropped .bash_profile — rustup, nvm and conda all
# write one — from silently shadowing everything here, leaving a login bash with
# no PATH, no EDITOR and no tool integrations.
#
# Exactly one branch runs, so nothing is sourced twice:
#   interactive  -> .bashrc, which carries the history and vi settings and the
#                   zsh handoff, and loads the same ~/.config/sh files.
#   non-interactive login (`ssh host cmd`, `bash -lc`, rsync) -> .profile,
#                   because .bashrc returns at its own interactive guard.
# shellcheck source=/dev/null
case $- in
    *i*) [ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc" ;;
    *)   [ -r "$HOME/.profile" ] && . "$HOME/.profile" ;;
esac
