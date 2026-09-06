# Same glob loader as .bashrc and .zshrc. Naming the files individually drifts
# the moment one is added or renumbered, and a missing `.` target exits a
# non-interactive shell outright.
for f in "$HOME"/.config/sh/*.sh; do
    # shellcheck source=/dev/null  # glob target, not knowable statically
    [ -r "$f" ] && . "$f"
done
unset f
