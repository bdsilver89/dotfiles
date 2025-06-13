return {
  "olimorris/codecompanion.nvim",
  cmd = {
    "CodeCompanion",
    "CodeCompanionChat",
    "CodeCompanionCmd",
    "CodeCompanionActions",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion Chat" },
    { "<leader>aa", "<cmd>CodeCompanionChat Add<cr>", mode = "x", desc = "Add to CodeCompanion Chat" },
  },
  opts = function()
    local config = require("codecompanion.config").config

    local diff_opts = config.display.diff.opts
    table.insert(diff_opts, "context:99") -- Setting the context to a very large number disables folding.

    return {
      strategies = {
        inline = {
          keymaps = {
            accept_change = {
              modes = { n = "<leader>ay" },
              description = "Accept the suggested change",
            },
            reject_change = {
              modes = { n = "<leader>an" },
              description = "Reject the suggested change",
            },
          },
        },
      },
      display = {
        diff = { opts = diff_opts },
      },
    }
  end,
}
