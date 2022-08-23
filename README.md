# Dotfiles

These are my personal dotfiles.
**Warning**: Use these files at your own risk.

## Install All

1. `git clone http://github.com/bdsilver89/dotfiles.git && cd dotfiles`
2. `./install_all.sh`

## Install Individual Configuration

1. `cd xxx` (e.g. nvim, zsh, or tmux)
2. `./install.sh`

## NeoVim Setup

Requires [NeoVim](https://neovim.io/) (>=0.7)

- [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim) - A plugin manager for Neovim
- [svrana/neosolarized.nvim](https://github.com/svrana/neosolarized.nvim) - A truecolor, solarized dark colorscheme
- [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) - A blazing fast and easy to configure Neovim statusline written in Lua
- [onsails/lspkind-nvim](https://github.com/onsails/lspkind-nvim) - VSCode-like pictograms
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) - Snippet Engine for Neovim written in Lua
- [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) - nvim-cmp source for neovim's built-in LSP
- [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer) - nvim-cmp source for buffer words
- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) - A completion engine plugin for neovim written in Lua
- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - A collection of configurations for Neovim's built-in LSP
- [jose-elias-alvarez/null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) - Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
- [MunifTanjim/prettier.nvim](https://github.com/MunifTanjim/prettier.nvim) - Prettier plugin for Neovim's built-in LSP client
- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) - Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP servers, linters, and formatters
- [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) - Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
- [glepnir/lspsaga.nvim](https://github.com/glepnir/lspsaga.nvim) - A light-weight lsp plugin based on neovim's built-in lsp with a highly performant UI
- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - [Treesitter](https://github.com/tree-sitter/tree-sitter) configurations and abstraction layer for Neovim
- [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) - Lua `fork` of vim-web-devicons for neovim
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - A highly extendable fuzzy finder over lists
- [nvim-telescope/telescope-file-browser.nvim](https://github.com/nvim-telescope/telescope-file-browser.nvim) - File Browser extension for telescope.nvim
- [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) - Autopairs
- [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) - Use treesitter to auto close and auto rename html tag
- [norcalli/nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua) - A high-performance color highlighter
- [akinsho/nvim-bufferline.lua](https://github.com/akinsho/nvim-bufferline.lua) - A snazzy bufferline
- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Git integration for buffers
- [dinhhuy258/git.nvim](https://github.com/dinhhuy258/git.nvim) - A simple clone of the plugin vim-fugitive
- [folke/zen-mode.nvim](https://github.com/folke/zen-mode.nvim) - Distraction-free mode
- [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) - Markdown live preview
- [terrortylor/nvim-comment](https://github.com/terrortylor/nvim-comment) - A comment toggler
- [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) - Manage multiple terminal windows
- [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) - Indent guides
- [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify) - A notification manager

### LSP Config
The following language servers are used for lspconfig:
- [tsserver](https://github.com/typescript-language-server/typescript-language-server) - Typescript
- [sourcekit](https://github.com/apple/sourcekit-lsp) - Swift
- [sumneko_lua](https://github.com/sumneko/lua-language-server) - Lua
- [tailwindcss](https://github.com/tailwindlabs/tailwindcss) - CSS
- [pyright](https://github.com/microsoft/pyright) - Python
- [gopls](https://github.com/golang/tools/tree/master/gopls) - Go
- [rust_analyzer](https://github.com/rust-lang/rust-analyzer) - Rust
- [cmake-language-server](https://github.com/regen100/cmake-language-server) - CMake
- [clangd](https://github.com/clangd/clangd) - C/C++

## Shell setup

- [Oh My Zsh](https://ohmyz.sh/)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like autosuggestions for zsh
- [exa](https://github.com/ogham/exa) - Optional replacement for 'ls'
- [bat](https://github.com/sharkdp/bat) - Optional replacement to 'cat'
- [fd](https://github.com/sharkdp/fd) - Optional alternative to 'find'

