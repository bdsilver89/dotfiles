# dotfiles

chezmoi-managed dotfiles for macOS, Debian/Ubuntu, RHEL/Fedora, Windows, and WSL.

Shell config is POSIX-first: `~/.profile`, `~/.bashrc` and `~/.zshrc` are thin
loaders that source `~/.config/sh/*.sh`, so bash and zsh share one set of
PATH/env/alias definitions. Only zsh-specific settings live in
`~/.config/zsh/*.zsh`.

## Layout

| Path | What it is |
| --- | --- |
| `.chezmoiroot` | Contains `home` — chezmoi treats `home/` as the source tree, not the repo root |
| `home/` | The chezmoi source tree |
| `home/.chezmoi.toml.tmpl` | Config template; prompts for `role` on `chezmoi init` |
| `home/.chezmoidata/packages.yaml` | The entire tool inventory, consumed by the install scripts |
| `home/run_onchange_*` | Package/tooling install scripts, re-run when their rendered content changes |
| `home/.chezmoiremove` | Paths deleted from `$HOME` on apply — see below |
| `home/dot_*` | Files that land in `$HOME` |

## New machine

Clone into `~/dotfiles` and apply in one step:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply \
  --source="$HOME/dotfiles" git@github.com:bdsilver89/dotfiles.git
```

Drop `--source` to use chezmoi's default location, `~/.local/share/chezmoi`.
Either works; `~/dotfiles` is just easier to open in an editor.

You are asked for the machine's `role` — `desktop` or `headless`. Desktop adds
GUI apps (terminal, editors); headless installs CLI tooling only. Answer
non-interactively with `--promptChoice role=headless`. That flag is keyed on the
*prompt string* in `.chezmoi.toml.tmpl`, not the data key; both are `role` here
deliberately, so the flag stays short.

`init` writes `~/.config/chezmoi/chezmoi.toml` — never committed — recording
both the role and `sourceDir`, so every later `chezmoi` command finds the repo
with no flags.

## Hooking up an existing clone

If the repo is already on disk (local development, or a clone made by hand),
point chezmoi at it by running `init` with no repository argument:

```sh
chezmoi init --source="$HOME/dotfiles" --promptChoice role=desktop
```

That renders the config template and records `sourceDir` without touching the
working tree. Verify with:

```sh
chezmoi source-path        # -> ~/dotfiles/home
chezmoi git -- remote -v   # -> operates on ~/dotfiles
chezmoi status             # read-only; shows what apply would change
```

`source-path` reporting `~/dotfiles/home` rather than `~/dotfiles` is correct —
that is `.chezmoiroot` being applied. `chezmoi cd` and `chezmoi git` still land
on the repo root, because the config records `.chezmoi.workingTree`, not
`.chezmoi.sourceDir`. Recording the latter would send chezmoi looking for
`home/home`.

`--source` on its own is **not** persisted — it applies to that one invocation
only. Re-running `init` as above is what makes it stick.

## Daily use

| Task | Command |
| --- | --- |
| Edit a config | `chezmoi edit --watch ~/.config/nvim/init.lua` |
| Capture an out-of-band edit | `chezmoi add ~/.tmux.conf` |
| See drift | `chezmoi status` / `chezmoi diff` |
| Apply | `chezmoi apply` |
| Publish | `chezmoi cd && git commit -am "..." && git push` |
| Pull elsewhere | `chezmoi update` |

`chezmoi status` letter codes: `A` add, `M` modify, `D` delete, `R` run a script.

After changing `.chezmoi.toml.tmpl`, existing machines need `chezmoi init` again
to regenerate their config — `apply` alone will not pick up a new prompt, and
chezmoi prints a warning telling you so.

## Development

### Source-tree naming

chezmoi derives the target path and mode from the source filename. The
attributes that matter here:

| Prefix / suffix | Effect |
| --- | --- |
| `dot_foo` | → `~/.foo` |
| `executable_foo` | → `~/foo`, mode `+x` |
| `run_onchange_<name>` | Script run on `apply` whenever its rendered content changes |
| `run_onchange_before_` / `_after_` | Run before / after the rest of the apply |
| `.tmpl` | **Render as a Go template.** Without it the file is copied verbatim |

**The `.tmpl` suffix is not optional for scripts.** chezmoi does not template
scripts implicitly. A `run_onchange_x.sh` full of `{{ ... }}` is written and
executed literally, and bash dies on the first brace. Every script in this repo
carries it for that reason — `.sh.tmpl`, or `.ps1.tmpl` for the Windows one.

### Template data

`home/.chezmoidata/packages.yaml` is merged into the template namespace under
its own top-level keys. Everything in this repo is nested under a single
`packages:` key, so it is addressed as `.packages.core`, `.packages.dnf_names`
and so on. A key added at the *file's* top level would be `.foo`, not
`.packages.foo` — an easy way to silently break a script, since chezmoi runs
templates with `missingkey=error`.

The `role` answer is available as `.role`. Platform facts come from chezmoi:
`.chezmoi.os` (`darwin` / `linux` / `windows`) and `.chezmoi.osRelease.id`
(`debian`, `ubuntu`, `fedora`, `rhel`, `rocky`, …).

### Adding a package

The package lists are named for *what installs them*, because that is the only
thing `packages.yaml` is consumed for. Pick the list by installer, not by how
the tool feels:

| List | Installer | Use when |
| --- | --- | --- |
| `core` | `brew` / `apt-get` / `dnf` | The OS package manager has a version you can live with |
| `mise` | `mise`, every OS | It doesn't, or the distro doesn't ship it at all |
| `vendor` | The tool's own installer | It updates itself, so a version manager would only fight it |
| `desktop` | `brew --cask` / `winget` | GUI app, `role = desktop` only |

**`core`** — add the name. If a distro names it differently, add the mapping to
`packages.apt_names` or `packages.dnf_names`; the install scripts look each name
up with `index $.packages.<map> . | default .`. If the binary name also differs
(Debian's `bat` → `batcat`), add a symlink to the bottom of the Debian script
and an alias to `dot_config/sh/20-aliases.sh`.

**`mise`** — add the name as it appears in mise's registry
(<https://mise.jdx.dev/registry.html>); check it there rather than guessing,
since a name that does not resolve fails the whole apply. Nothing else to do:
`dot_config/mise/config.toml.tmpl` renders the list into `[tools]` and
`run_onchange_after_20-mise-install.sh.tmpl` runs `mise install`. Language
runtimes go in `packages.mise_runtimes` in `name@version` form instead — same
rendered file, kept separate here because they are versioned deliberately while
tools track `latest`.

**`vendor`** — add all four fields. `command` is the binary to test for, which
is not always the package name (`claude-code` installs `claude`); `args` is
passed to the installer and must be present even when empty, because chezmoi
renders templates with `missingkey=error`.

Vendor installers are run only when `command` is missing, so they bootstrap and
then get out of the way. Check a new one for two behaviours before adding it: an
installer that appends to `~/.zshrc` or `~/.bashrc` will fight the managed
copies and show up as drift on every apply, and one that needs `sudo` cannot run
from an apply unattended.

### Adding a platform

Copy an existing `run_onchange_before_10-packages-*`. The whole file is
wrapped in one guard, so only the matching platform's script renders to
anything; the others render empty and are no-ops:

```
{{- if and (eq .chezmoi.os "linux") (has .chezmoi.osRelease.id (list "fedora" "rhel")) -}}
...
{{- end }}
```

Close with `{{- end -}}`, not `{{- end }}`. The latter leaves a trailing newline,
so the file renders to one byte rather than zero on every other platform —
non-empty enough that chezmoi schedules the script to run, then executes a file
with no shebang. The Windows script closes with the trimming form for that
reason; the Debian and RHEL ones predate the problem and still emit the newline.

chezmoi picks the interpreter from the extension left after `.tmpl` is stripped,
via `[interpreters.<ext>]` in `.chezmoi.toml.tmpl`. That is why the Windows
script is `.ps1.tmpl` and why its `pwsh` block is inside the file's
`eq .chezmoi.os "windows"` guard — the interpreter only needs to exist on the
platform that runs it.

### Testing without touching `$HOME`

All examples below run from the **repo root** — where `chezmoi cd` puts you,
since the config records the working tree. Template paths therefore carry the
`home/` prefix, even though chezmoi itself resolves `.chezmoiroot` internally.
No `--source` flag is needed once the repo is hooked up; add
`--source=/path/to/repo` only when driving a clone that chezmoi does not know
about.

Render one template against the current machine's data:

```sh
chezmoi execute-template < home/run_onchange_before_10-packages-darwin.sh.tmpl
```

To exercise a platform this machine is not, stub out the guard and the
`osRelease` lookups, then syntax-check the result. A branch that renders empty
means the stub did not take:

`--config` *replaces* the config rather than merging into it, so the throwaway
file has to carry `sourceDir` too — otherwise chezmoi looks for `packages.yaml`
in the default source directory and every lookup fails with
`map has no entry for key "packages"`.

```sh
printf 'sourceDir = "%s"\n\n[data]\n    role = "desktop"\n' "$PWD" > /tmp/role.toml

check() {   # check <template> <osRelease id>
  sed -e '1s/.*/{{- if true -}}/' -e "s/\.chezmoi\.osRelease\.id/\"$2\"/g" "$1" \
    | chezmoi --config=/tmp/role.toml execute-template > /tmp/rendered.sh || return 1
  [ -s /tmp/rendered.sh ] || { echo "EMPTY — guard stub missed"; return 1; }
  sh -n /tmp/rendered.sh && echo "OK"
}

check home/run_onchange_before_10-packages-rhel.sh.tmpl   rocky
check home/run_onchange_before_10-packages-rhel.sh.tmpl   fedora
check home/run_onchange_before_10-packages-debian.sh.tmpl ubuntu
```

Run that under `bash`, not `zsh` — the helper relies on word splitting.

Diff the whole tree into a throwaway directory instead of `$HOME`:

```sh
mkdir -p /tmp/dest
chezmoi --config=/tmp/role.toml --destination=/tmp/dest \
        --persistent-state=/tmp/state.boltdb diff
```

Use `diff` rather than `apply --dry-run` — `diff` prints the rendered script
bodies, which is the point of the exercise. And never `apply` for real against a
scratch destination: `--destination` redirects where *files* are written, but
the `run_onchange_before_` scripts still execute, and they invoke
`brew` / `apt-get` / `dnf` against the actual machine.

### Checks worth running before pushing

From the repo root:

```sh
cd home
bash -n dot_bashrc dot_bash_profile dot_profile dot_config/sh/*.sh dot_config/tmux/*.sh
zsh  -n dot_zshrc dot_config/zsh/*.zsh
tmux -f dot_tmux.conf -L cfgcheck start-server \; kill-server
for f in $(find . -name '*.tmpl' ! -name '.chezmoi.toml.tmpl'); do
  chezmoi execute-template < "$f" >/dev/null || echo "FAIL $f"
done
grep -rl '{{' . | grep -v -e '\.tmpl$' -e '\.chezmoiignore$' -e '\.chezmoiremove$'
```

The template loop only covers branches this machine matches; the others render
empty and pass trivially. Use `check` above for the rest.
`.chezmoi.toml.tmpl` is excluded because its `promptChoiceOnce` only resolves
under `init`, so it fails the loop for reasons that are not bugs.

The `grep` is the more important half, and it should print nothing. The two
exclusions are not oversights: chezmoi templates `.chezmoiignore` and
`.chezmoiremove` implicitly, unlike scripts, so both legitimately carry `{{ }}`
with no `.tmpl` suffix and would otherwise be reported every run. It catches
the failure the loop structurally cannot: a file full of `{{ ... }}` that was
never given the `.tmpl` suffix is not a broken template, it is not a template at
all, so there is nothing for `execute-template` to fail on. chezmoi copies the
braces through verbatim and the breakage lands in `$HOME`. That is survivable in
a shell rc, which ignores what it cannot parse; it is not survivable in
`~/.gitconfig`, where git aborts on the first brace with `bad config line` and
every git command on the machine stops working — including the ones you would
reach for to undo it.

## Machine-local overrides

Not tracked, optional. `~/.config/sh/local.sh` is picked up by the same glob
that loads the rest of `~/.config/sh`, and sorts last, so it wins — use it for
env vars, proxies and API keys.

`~/.gitconfig.local` is the git equivalent, but it does **not** win. The
`[include]` sits at the top of `dot_gitconfig.tmpl`, and git resolves an include
in place, so anything the tracked file sets afterwards overrides it. In practice
the local file can only supply keys the tracked one leaves alone — a signing
key, a credential helper — and cannot change `user.email` on a work machine.
Moving the `[include]` block to the bottom of the file reverses that, matching
how `local.sh` behaves.

`~/.config/wezterm/machine.lua` is the terminal equivalent. wezterm puts its
config directory on `package.path`, so `wezterm.lua` ends with a `pcall` require
of `machine` and copies whatever table it returns over the config. Absent, the
`pcall` fails silently and nothing happens. Use it for per-machine font sizes
and for `ssh_domains`, which is a list of internal hostnames that has no
business being tracked.

`~/.config/alacritty/machine.toml` is the same idea for Alacritty: listed last
in `general.import`, which skips missing files. `catppuccin-mocha.toml` in the
same directory is an unmodified copy of the upstream theme from
`catppuccin/alacritty`, imported the same way.

## Known gaps

- `packages.desktop.linux` only lists `alacritty`, not wezterm — wezterm isn't
  in the Debian, Ubuntu or Fedora repos and needs its own apt/rpm repo or a
  release download.
- On native Windows only `packages.desktop.windows.winget` is installed — host
  GUI apps. The core CLI tooling lives in WSL, which is just the Linux path;
  the mise, gh-extensions and vendor scripts all skip Windows outright.
  `workmux` would not belong in the winget list — there is no native tmux.
- Nothing removes a *package* once you delete it from `packages.yaml`; the
  install scripts only ever add. Files are different: dropping one from the
  source tree leaves the copy in `$HOME` untouched, and `.chezmoiremove` is
  what deletes it on the next apply.
- `dot_gitconfig.tmpl` sets `core.pager = delta`, and git treats a missing pager
  as fatal — `unable to execute pager 'delta'`, exit 128, on every command that
  paginates. So an apply that writes the dotfiles but fails before installing
  `git-delta` leaves git unusable rather than merely unstyled. The `nvim` diff
  and merge tools are not exposed the same way: git falls back to a default when
  the configured tool is missing, and only `git difftool` touches them at all.
- No CI.
