-- Infrastructure other modules build on top of.
require("plugins.lspconfig")
require("plugins.mason")
require("plugins.blink")

-- Editor / UI.
require("plugins.catppuccin")
require("plugins.nvim-web-devicons")
require("plugins.treesitter")
require("plugins.flash")
require("plugins.fzf-lua")
require("plugins.oil")
require("plugins.vim-sleuth")
require("plugins.vim-tmux-navigator")

-- Language tooling (depends on blink capabilities + mason).
require("plugins.jdtls")


 vim.pack.add({
    "https://github.com/b0o/SchemaStore.nvim",
    "https://github.com/folke/flash.nvim",
    "https://github.com/gbprod/yanky.nvim",
    "https://github.com/iamcco/markdown-preview.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/igorlfs/nvim-dap-view",
    "https://github.com/itchyny/vim-highlighturl",
    "https://github.com/jbyuki/one-small-step-for-vimkind",
    "https://github.com/kylechui/nvim-surround",
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/linrongbin16/gitlinker.nvim",
    "https://github.com/lukas-reineke/indent-blankline.nvim",
    "https://github.com/MagicDuck/grug-far.nvim",
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/mfussenegger/nvim-jdtls",
    -- "https://github.com/monkoose/neocodeium",
    "https://github.com/zbirenbaum/copilot.lua",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    "https://github.com/saghen/blink.cmp",
    "https://github.com/saghen/blink.lib",
    "https://github.com/sindrets/diffview.nvim",
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/stevearc/quicker.nvim",
    "https://github.com/theHamsta/nvim-dap-virtual-text",
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/windwp/nvim-ts-autotag",
  })
