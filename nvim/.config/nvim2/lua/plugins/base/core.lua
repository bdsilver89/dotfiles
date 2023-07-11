return {
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",
  {
    "echasnovski/mini.bufremove",
    -- stylua: ignore
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end,  desc = "Delete Buffer (Force)" },
    },
  },
  {
    "folke/neoconf.nvim",
    cmd = "Neoconf",
    config = true,
  },
  {
    "folke/neodev.nvim",
    opts = {},
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>",  desc = "Tmux/window navigate left" },
      { "<c-j>",  desc = "Tmux/window navigate down" },
      { "<c-k>",  desc = "Tmux/window navigate up" },
      { "<c-l>",  desc = "Tmux/window navigate right" },
      { "<c-\\>", desc = "Tmux/window navigate previous" },
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 0
    end,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = {
        "buffers",
        "curdir",
        "tabpages",
        "winsize",
        "help",
        "globals",
        "skiprtp",
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end,                desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end,                desc = "Exit without saving session" },
    },
  },
}
