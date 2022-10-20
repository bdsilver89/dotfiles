local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  -- tools
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'
  -- use 'antoinemadec/FixCursorHold.nvim'
  use { 'dstein64/vim-startuptime', cmd = 'StartupTime' }

  -- editor
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'nvim-treesitter/nvim-treesitter-context', after = 'nvim-treesitter' }
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-file-browser.nvim'
  use 'terrortylor/nvim-comment'
  -- use 'sbdchd/neoformat'
  use 'ThePrimeagen/harpoon'
  use 'ThePrimeagen/git-worktree.nvim'
  use 'akinsho/toggleterm.nvim'

  -- lsp
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'onsails/lspkind-nvim'
  use 'glepnir/lspsaga.nvim'
  use 'simrat39/symbols-outline.nvim'
  use 'L3MON4D3/LuaSnip'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  -- debug and testing
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  use 'theHamsta/nvim-dap-virtual-text'

  -- ui
  use 'nvim-lualine/lualine.nvim'
  use 'akinsho/nvim-bufferline.lua'
  use 'kyazdani42/nvim-web-devicons'
  use 'folke/tokyonight.nvim'
  use 'gruvbox-community/gruvbox'
  use 'lewis6991/gitsigns.nvim'
  use 'mbbill/undotree'
end)
