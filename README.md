# dotfiles

[![ci](https://github.com/bdsilver89/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/bdsilver89/dotfiles/actions/workflows/ci.yml)

chezmoi-managed dotfiles for Linux, WSL, macOS, and Windows.

## New Machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:bdsilver89/dotfiles.git
```

Or, on a machine with nothing installed at all — this adds the Xcode CLT / apt
prerequisites, chezmoi itself, and non-interactive answers:

```sh
sh -c "$(curl -fsLS https://raw.githubusercontent.com/bdsilver89/dotfiles/main/bootstrap.sh)"
./bootstrap.sh --role headless --theme dracula --no-work --yes
```

You will be asked for the machine's role (`desktop` or `headless`), whether it is a work machine, a git email, and a colour scheme.
Answers are stored in `~/.config/chezmoi/chezmoi.toml`, which is never committed.

## Colour scheme

One variable drives eleven tools. `theme` with no arguments lists the schemes and marks the active one:

```sh
theme            # onedark / catppuccin-mocha / dracula / rose-pine
theme dracula    # switch and re-apply
```

Running tmux servers need `prefix-r` and running editors need a restart; everything else re-renders on the spot.

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
