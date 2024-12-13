return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local snacks = require("snacks")

      opts.dashboard = {
        sections = {
          { section = "header" },
          { title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { title = "Projects", section = "projects", indent = 2, padding = 1 },
          {
            title = "Git Status",
            section = "terminal",
            enabled = snacks.git.get_root() ~= nil,
            cmd = "git status --short --branch --renames",
            height = 5,
            indent = 2,
            padding = 1,
            ttl = 5 * 60,
          },
          { section = "startup" },
        },
      }

      opts.scroll = { enabled = false }

      return opts
    end,
  },

  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true,
      },
    },
  },
}
