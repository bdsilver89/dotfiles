# Neovim configuration — design

**Date:** 2026-08-06
**Status:** approved, not yet implemented
**Location:** `config/nvim/` (symlinked from `~/.config/nvim`)

## Goal

An IDE-grade Neovim configuration that does not pay for its features at startup.

The two requirements are in tension only if you let them be. Nearly everything on
the feature list — debugging, database, GitHub review, testing — is inherently
on-demand, so it can be deferred to the moment of first use. The eager cost is
limited to the editing core: colorscheme, statusline, treesitter, LSP,
completion, and the picker.

### Requirements

- Fast startup: **80ms is a hard ceiling**, lower is better.
- Built on `vim.pack` (Neovim's native plugin manager).
- LSP for Java, Rust, Python, C++, Bash, plus supporting languages.
- Treesitter, git, GitHub (PRs and Actions), debugger, testing, linting,
  formatting, and database integration.

### Target platforms

WSL2/Linux (primary), macOS, and remote Linux dev boxes for work. **Windows
native is out of scope**, which removes the hardest DAP and jdtls edge cases.

Remote dev boxes impose three constraints that shape the design:

- OSC52 clipboard, since there is no X forwarding. Neovim 0.12 provides this.
- Graceful degradation when a tool is not installed and cannot be.
- A committed lockfile, so a fresh clone reproduces exact plugin revisions.

### Measured baseline

On the primary machine, `nvim --clean` starts in **7.6–8.1ms**. The current
stripped-down config starts in 8.5–9.6ms. That leaves roughly **70ms of
headroom** under the ceiling, which is generous enough that eager-loading
high-traffic plugins is viable and clever deferral machinery is not required.

## Startup accounting

`defer`-style tricks can hide work from `nvim --startuptime`, so the budget is
defined in two parts and both are held:

- **T1** — startup through `VimEnter`. What `--startuptime` reports.
  **Hard ceiling 80ms. Target ≤50ms with the full stack installed** (≈40ms
  through Phase 1, since Phase 2 adds fzf-lua eagerly).
- **T2** — deferred work after `VimEnter`. Invisible to `--startuptime`, but
  felt as stutter. Must never block input.

Every phase ends with a measured T1, not an assumed one.

## Architecture

### Layout

```
config/nvim/
├── init.lua              # ~25 lines: vim.loader.enable(), colorscheme, requires. Names no plugins.
├── nvim-pack-lock.json   # committed — pins revisions across all three machine types
├── stylua.toml
├── lsp/*.lua             # native vim.lsp.config server definitions, auto-read from rtp
├── after/ftplugin/*.lua  # per-filetype options (java shiftwidth=4, qf, ...)
├── plugin/*.lua          # ONE FILE PER PLUGIN — auto-sourced by Neovim after init.lua
└── lua/
    ├── pack.lua          # the vim.pack helper (~120 lines)
    ├── options.lua
    ├── keymaps.lua
    ├── autocmds.lua
    ├── commands.lua
    ├── icons.lua         # shared icon table
    ├── statusline.lua
    ├── winbar.lua
    ├── lsp.lua           # on_attach, LSP keymaps, diagnostic config
    └── tools.lua         # :ToolSync and :checkhealth tools
```

Two rules keep this coherent:

1. **`lua/` core modules never touch a plugin.** If `plugin/` were deleted
   entirely, Neovim would still open and edit correctly. This is what makes the
   config survivable on a box with no network.
2. **Every file in `plugin/` is a leaf.** It registers triggers and returns. No
   cross-requires between plugin files; shared behavior lives in `lua/`.

Using Neovim's built-in `plugin/` directory rather than a `lua/plugins/` module
list means there is no require bookkeeping and no manual load order. Disabling a
plugin is renaming one file — the same bisecting workflow already in use, but
without editing `init.lua`.

### `lua/pack.lua`

The helper is convention-driven rather than trigger-driven. It is adapted from
[MariaSolOs/dotfiles](https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/vim-pack.lua),
with two changes noted below.

**Spec fields:**

| Field | Meaning |
|---|---|
| `src` | `owner/repo`; expanded to a GitHub URL |
| `name` | override the directory name |
| `version` | branch, tag, commit, or `vim.version.range()` |
| `module_name` | override the inferred `require` name |
| `opts` | table, or a function returning a table, passed to `setup()` |
| `on_setup` | function run after load and setup |
| `setup = false` | skip `require`/`setup` entirely — for vimscript-only or data-only plugins |

The module name is inferred from the repo name with a trailing `.nvim`
stripped. `opts`-as-a-function allows a plugin to be `require`d inside its own
options block without loading it earlier than needed.

**Public API:**

```lua
add(specs)                        -- eager
add_on_event(event, specs)        -- any autocmd event
add_on_file_type(patterns, specs) -- FileType
add_on_cmd(cmds, specs)           -- first invocation of a user command
on_plugin_update(name, cmd)       -- build hook via PackChanged
```

`add()` batches all sources into a single `vim.pack.add()` call so installs run
in parallel, then configures each plugin in order.

**Change 1 — trigger replay.** The upstream helper registers `once = true`
autocmds but never re-fires them, so the buffer that caused the load is not
processed. Upstream works around this by hand in `plugin/jdtls.lua`:

```lua
-- Attach to the buffer that triggered this load (the FileType autocmd above only
-- fires for future java buffers).
if vim.bo.filetype == 'java' then start_jdtls() end
```

This design folds replay into the helper: after loading and setup, it calls
`nvim_exec_autocmds` to re-fire the triggering event on the triggering buffer.
Every `add_on_event` and `add_on_file_type` plugin then gets correct
first-buffer behavior without per-plugin patching.

**Change 2 — `add_on_cmd`.** The upstream helper has no command trigger. This
stack includes heavyweights used weekly rather than continuously (`:Octo`,
`:DBUI`, `:Git`); putting them on `UIEnter` would add T2 cost every session for
things usually untouched. `add_on_cmd` registers a stub user command that, on
first invocation, loads the plugin, deletes the stub, and re-invokes the real
command preserving args, bang, and range. Roughly 15 lines.

**Explicitly rejected: a `keys` trigger.** For high-traffic plugins the load
cost is paid every session anyway, so a keymap trigger buys nothing but
complexity. The sharper technique — used for `vim.ui.select` — is deferring the
`require`, not the plugin.

### Trigger assignment

| Trigger | Used for |
|---|---|
| eager | colorscheme, treesitter, blink, fzf-lua, schemastore, `vim.lsp.enable` |
| `UIEnter` | oil, flash, mini.clue, devicons — the "VeryLazy" bucket |
| `BufReadPre`,`BufNewFile` | gitsigns |
| `FileType` | jdtls, rustaceanvim, dap adapters, render-markdown |
| `BufWritePre` / `BufWritePost` | conform / nvim-lint |
| `add_on_cmd` | fugitive, octo, dadbod |

### LSP loading

`nvim-lspconfig` 2.x is a directory of `lsp/<server>.lua` files. It is added to
the runtimepath and **never `require`d**. Servers are configured by local
`lsp/*.lua` files and activated with `vim.lsp.enable({...})`. No
`mason-lspconfig` bridge.

One measured caveat: `vim.lsp.enable()` resolves each server's config file at
enable time — it raises an error if a config file errors — so it is not free.
For ~12 servers this is expected to cost 3–8ms. **If it measures above 5ms it
moves from eager into a `once` `BufReadPre` autocmd.** This is a measurement
checkpoint in Phase 1, not a guess to be made now.

## Plugin stack

| Domain | Plugin | Trigger |
|---|---|---|
| Colorscheme | `catppuccin` | eager |
| Treesitter | `nvim-treesitter` (main branch) | eager add, parse on `FileType` |
| Completion | `blink.cmp`, `blink.lib`, `LuaSnip`, `friendly-snippets` | eager |
| LSP configs | `nvim-lspconfig` (rtp only) | eager add |
| Schemas | `schemastore.nvim` (`setup = false`) | eager |
| Picker | `fzf-lua` | eager |
| Explorer | `oil.nvim` | `UIEnter` |
| Motions | `flash.nvim` | `UIEnter` |
| Keymap hints | `mini.clue` | `UIEnter` |
| Icons | `nvim-web-devicons` | `UIEnter` |
| Git signs | `gitsigns.nvim` | `BufReadPre`,`BufNewFile` |
| Git ops | `vim-fugitive` | `add_on_cmd { 'Git', 'G' }` |
| GitHub review | `octo.nvim` | `add_on_cmd { 'Octo' }` |
| GitHub browse/CI | `gh-dash` (external TUI) | tmux split |
| Format | `conform.nvim` | `BufWritePre` |
| Lint | `nvim-lint` | `BufWritePost` |
| Debug | `nvim-dap`, `nvim-dap-view`, `nvim-dap-virtual-text` | `FileType` |
| Rust | `rustaceanvim` (LSP + DAP + testables) | `FileType rust` |
| Java | `nvim-jdtls`, java-debug, vscode-java-test | `FileType java` |
| Python debug | `nvim-dap-python` | `FileType python` |
| Test | `neotest`, `neotest-python` | `add_on_cmd` |
| Database | `vim-dadbod`, `-ui`, `-completion` | `add_on_cmd { 'DBUI' }` |
| Markdown | `render-markdown.nvim` | `FileType markdown` |

### Selection notes

- **`rustaceanvim`** replaces hand-configured `rust_analyzer` and bundles
  codelldb DAP plus testables. Actively maintained.
- **`nvim-dap-view`** over `nvim-dap-ui`: lighter and currently maintained;
  `nvim-dap-ui` carries 107 open issues.
- **`mini.clue`** over `which-key.nvim`: actively maintained and much lighter;
  which-key last shipped 2025-10-28.
- **`diffview.nvim` is rejected** — unmaintained since 2024-08-02. Octo ships
  its own review panel and no longer requires it.
- **`gh-dash`** is a terminal TUI, not a plugin, and is by a wide margin the
  most-used GitHub tool in this space (12.2k stars vs octo's 3.3k). It covers
  browsing and CI; octo covers line-level review comments and approvals. They
  are used together because they are good at different halves of the job.

## Tool provisioning

Hybrid: toolchain-bound servers come from their toolchain, Mason handles the
long tail. **Mason is `require`d only inside `:ToolSync` and never appears in
any startup path.**

| Server / tool | Language | Source |
|---|---|---|
| `rust_analyzer` | Rust | `rustup component add` (via rustaceanvim) |
| `clangd` | C/C++ | system `apt` / `brew` |
| `basedpyright`, `ruff` | Python | `uv tool install` |
| `gopls` | Go | `go install` |
| `taplo` | TOML | `cargo install` |
| `jdtls` | Java | Mason |
| `lua_ls` | Lua | Mason |
| `bashls` | Bash | Mason |
| `jsonls`, `yamlls` | JSON/YAML | Mason (+ `schemastore.nvim`) |
| `lemminx` | XML | Mason |
| `neocmake` | CMake | Mason |

Formatters and linters follow the same table: `stylua`, `shfmt`, `shellcheck`,
`clang-format`, `google-java-format`, `ruff format`.

`lua/tools.lua` declares this as data and provides:

- **`:ToolSync`** — checks each entry with `vim.fn.executable()`, reports what
  is missing, and offers to install it by the declared method.
- **`:checkhealth tools`** — reports per-language what is present and what is
  missing. This is the degradation story for locked-down work boxes: the config
  never hard-fails on a missing binary, it tells you what you do not have.

## Known risks

1. **Java is the heaviest integration by a wide margin.** `nvim-jdtls` is not a
   normal LSP: it is started per-buffer via `start_or_attach` with a hand-built
   `java` command line, a per-project workspace directory, and separately
   downloaded debug and test bundles. It is also the most sensitive to version
   drift. The primary machine has `mvn` but **no `gradle`**, so root detection
   keys on `pom.xml` first.

2. **`neotest-java` is the weakest component in the stack** — 74 stars, 12 open
   issues. C++ has no viable neotest adapter at all. Therefore neotest is used
   for **Python and Rust only**; Java and C++ get a small command shelling out
   to `mvn test -Dtest=...` and `ctest`. Less magic, far less breakage.

3. **`vim.lsp.enable()` cost is unmeasured.** Resolved by the Phase 1
   checkpoint described above.

## Phases

Each phase ends with a measured `--startuptime` number and a functional check.
A failed gate is fixed before the next phase begins — this is what keeps the
80ms ceiling real rather than aspirational.

| Phase | Contents | Gate |
|---|---|---|
| **0** | `init.lua`, `lua/pack.lua`, options, keymaps, autocmds, colorscheme, statusline, winbar, icons | T1 < 15ms; Neovim fully usable with zero plugins |
| **1** | treesitter, `lsp/*.lua`, `lua/lsp.lua`, blink + LuaSnip | T1 < 40ms; hover, definition, rename, diagnostics in Rust, Python, C++, Lua, Bash |
| **2** | fzf-lua, oil, gitsigns, fugitive, flash, mini.clue | T1 < 50ms; files, grep, symbols, diagnostics pickers all work |
| **3** | conform, nvim-lint, `tools.lua`, `:ToolSync`, `:checkhealth tools` | format-on-save in all five languages; `:ToolSync` reports honestly on a bare box |
| **4** | nvim-dap, dap-view, virtual-text, codelldb, debugpy, rustaceanvim | T1 within 2ms of Phase 3 (all `FileType`-gated); breakpoint and step in Rust, Python, C++ |
| **5** | nvim-jdtls, java-debug, vscode-java-test | jdtls attaches on a Maven project; Java breakpoint hits |
| **6** | neotest (Python, Rust), `mvn`/`ctest` commands | run nearest test, run file, failures visible |
| **7** | octo (`add_on_cmd`), gh-dash in Brewfile/bootstrap, dadbod | `:Octo pr list` works; `:DBUI` connects |
| **8** | bootstrap.sh and Brewfile wiring, macOS and remote-box verification, OSC52 clipboard | fresh clone → `nvim` → working config on all three machine types |

Phases 0–2 deliver a genuinely usable IDE and are the stated priority. Phases
4–8 are additive, and each is independently abandonable if it does not earn its
keep.

## Migration

The existing `config/nvim/` contains 339 lines across 10 files, with most
modules commented out of `init.lua`. `lua/options.lua`, `lua/autocmds.lua`, and
`lua/keymaps.lua` are kept as-is and become the Phase 0 core. The remaining
modules are superseded by their `plugin/*.lua` equivalents.

`config/nvim-custom/` is already deleted in the working tree and is not
restored. `config/nvim` was formerly a symlink to `config/astronvim`; it is now
a real directory and stays that way.
