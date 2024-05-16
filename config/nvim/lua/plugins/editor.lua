return {
  -- automatic shiftwidth/tabstop detection
  {
    "tpope/vim-sleuth",
    lazy = false,
  },

  -- (neo)vim/tmux window/pane navigation
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    opts = {
      signs = vim.g.enable_icons,
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup()

      wk.register({
        ["<leader><tab>"] = { name = "+tab" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>m"] = { name = "+harpoon" },
        ["<leader>q"] = { name = "+session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>t"] = { name = "+term" },
        ["<leader>w"] = { name = "+window" },
      })
    end,
  },
}
