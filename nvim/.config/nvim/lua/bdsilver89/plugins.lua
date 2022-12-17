local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd.packadd('packer.nvim')

packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/plenary.nvim' }
    }
  }
  use 'nvim-telescope/telescope-file-browser.nvim'

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'nvim-treesitter/nvim-treesitter-context', after = 'nvim-treesitter' }
  use 'ThePrimeagen/harpoon'
  use 'terrortylor/nvim-comment'
  use 'mbbill/undotree'
  use 'nvim-lualine/lualine.nvim'

  use {
    'rose-pine/neovim',
    as = 'rose-pine',
    config = function()
        vim.cmd('colorscheme rose-pine')
    end
  }

  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- lsp
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- completion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    }
  }

  use {
    'danymat/neogen',
    requires = 'nvim-treesitter/nvim-treesitter'
  }

  -- debug and testing
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  use 'theHamsta/nvim-dap-virtual-text'

--   -- ui
--  use 'akinsho/nvim-bufferline.lua'
--  use 'kyazdani42/nvim-web-devicons'
--   use 'lewis6991/gitsigns.nvim'
end)
