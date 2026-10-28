# Interactive only. Without this guard, scp/rsync/git-over-ssh and VS Code
# Remote's server startup all break.
case $- in *i*) ;; *) return ;; esac

# Hand off to zsh where chsh is blocked. LDAP/SSSD accounts have no
# /etc/passwd entry, so chsh can never work on those boxes.
# Escape hatch: ssh host -t bash --noprofile
if [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
    # /etc/profile.d has already run by now so skip it for zsh
    export ETC_PROFILE_SOURCED=1
    exec zsh -l
fi

. "$HOME/.config/shell/env.sh"

# Unquoted so the glob expands. A quoted glob does not expand — it would loop
# once over the literal pattern and source nothing at all.
for f in "$HOME"/.config/shell/interactive/*.sh "$HOME"/.config/shell/bash/*.bash; do
    # shellcheck source=/dev/null  # glob target, not knowable statically
    [ -r "$f" ] && . "$f"
done
unset f
