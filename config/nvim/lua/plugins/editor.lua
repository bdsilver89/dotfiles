return {
  -- LazyVim
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- telescope
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
  -- {
  --   "stevearc/oil.nvim",
  --   dependencies = {
  --     "nvim-tree/nvim-web-devicons",
  --   },
  --   -- stylua: ignore
  --   keys = {
  --     { "<leader>o", function() require("oil").open() end, desc = "Oil (float)" },
  --   },
  --   opts = {},
  --   config = true,
  -- },

  -- tmux/vim compat
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- expand git functionality
  -- NOTE: should consider dinhhuy258/git.nvim as lua rewrite of this?
  {
    "tpope/vim-fugitive",
    event = "LazyFile",
  },
}
