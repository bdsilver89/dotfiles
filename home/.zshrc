# (N) is zsh's null_glob qualifier: yields an empty list instead of erroring
# when nothing matches.
for f in "$HOME"/.config/shell/interactive/*.sh(N) "$HOME"/.config/shell/zsh/*.zsh(N); do
    . "$f"
done
unset f
