# dotfiles

chezmoi-managed dotfiles for Linux, WSL, macOS, and Windows.

## New Machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:bdsilver89/dotfiles.git
```

You will be asked for the machine's role (`desktop` or `headless`), whether it is a work machine, and a git email.
Answers are stored in `~/.config/chezmoi/chezmoi.toml`, which is never committed.

## Daily use

| Task | Command |
| --- | --- |
| Edit a config | `chezmoi edit --watch ~/.config/nvim/init.lua` |
| Capture an out-of-band edit | `chezmoi add ~/.tmux.conf` |
| See drift | `chezmoi status` / `chezmoi diff` |
| Publish | `chezmoi cd && git commit -am "..." && git push` |
| Pull elsewhere | `chezmoi update` |

## Machine-local overrides

Neither file is tracked. Both are optionsl.

- `~/.config/sh/local.sh` — env vars, proxies, API keys
- `~/.gitconfig.local` — email, signing keys, credential helpers
- `~/.ssh/conf.d/*.conf` — internal hosts


## Layout

- `home/` — the chezmoi source tree (see `.chezmoiroot`)
- `home/.chezmoidata/packages.yml` — the entire tool inventory
- `home/.chezmoiignore` — the role/pattern exclusion matrix
