return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  {
    "alexghergh/nvim-tmux-navigation",
    keys = {
      { "<c-h>", "<cmd>NvimTmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd>NvimTmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd>NvimTmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd>NvimTmuxNavigateRight<cr>" },
    },
    opts = {},
  },

  {
    "stevearc/oil.nvim",
    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Explorer Oil (Root Dir)",
      },
      {
        "_",
        function()
          require("oil").open(vim.uv.cwd())
        end,
        desc = "Explorer Oil (cwd)",
      },
    },
    opts = {},
  },

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

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Status" },
    },
    opts = {
      integrations = {
        diffview = true,
      },
    },
  },
}
