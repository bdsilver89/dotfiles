# (N) is zsh's null_glob qualifier: yields an empty list instead of erroring
# when nothing matches.
for f in "$HOME"/.config/sh/*.sh(N); do
    [ -r "$f" ] && . "$f"
done
for f in "$HOME"/.config/zsh/*.zsh(N); do
    [ -r "$f" ] && . "$f"
done
unset f
