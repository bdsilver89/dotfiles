return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = {
        group = vim.g.icons_enabled ~= false and "" or "+",
        separator = "-",
      },
      disable = {
        filetypes = {
          "TelescopePrompt",
        },
      }
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      wk.register({
        mode = { "n", "v" },
        ["<leader>b"] = { name = "buffer" },
      })

    end,
  },
}
