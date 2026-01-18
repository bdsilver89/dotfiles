return {
  {
    "nvim-lspconfig",
    opts = {
      codelens = {
        enabled = true,
      },
      diagnostics = {
        virtual_text = false,
      },
    },
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {},
  },

  {
    "stevearc/oil.nvim",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil file explorer" },
    },
    opts = {},
  },

  {
    "snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },

  {
    "NMAC427/guess-indent.nvim",
    event = "LazyFile",
    cmd = "GuessIndent",
    opts = {},
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateRight",
      "TmuxNavigateUp",
      "TmuxNavigateDown",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left pane" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower pane" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper pane" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right pane" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Go to previous pane" },
    },
  },
}
