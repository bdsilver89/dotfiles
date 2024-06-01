return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- navigate between nvim/vim and tmux panes easily
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- editorconfig + shiftwidth/tabstop automatic setting
  {
    "tpope/vim-sleuth",
    lazy = false,
  },

  -- telescope, change ui
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
      },
    },
  },

  -- oil as primary file explorer
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    -- stylua: ignore
    keys = {
      { "<leader>O", function() require("oil").open(LazyVim.root()) end, desc = "Explorer Oil (root)" },
      { "<leader>o", function() require("oil").open() end, desc = "Explorer Oil (cwd)" },
    },
    cmd = "Oil",
    opts = {},
  },

  -- undotree
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", "Undotree" },
    },
  },
}
