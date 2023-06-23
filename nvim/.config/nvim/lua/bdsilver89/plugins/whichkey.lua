return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      setup = {
        show_help = true,
        plugins = { spelling = true },
        key_labels = { ["<leader>"] = "SPC" },
        triggers = "auto",
        window = {
          border = "single",
          position = "bottom",
          margin = { 1, 0, 1, 0 },
          padding = { 1, 1, 1, 1 },
          winblend = 0,
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          align = "left",
        },
      },
      defaults = {
        prefix = "<leader>",
        mode = { "n", "v" },
        ["<tab>"] = { name = "+Tabs" },
        -- a = { name = "+AI" },
        b = { name = "+Buffer" },
        d = { name = "+Debug" },
        D = { name = "+Database" },
        f = { name = "+File/Find" },
        h = { name = "+Help" },
        j = { name = "+Jump" },
        g = { name = "+Git", h = { name = "Hunk" }, t = { name = "Toggle" } },
        -- n = { name = "+Notes" },
        o = { name = "+Overseer" },
        -- p = { name = "+Project" },
        q = { name = "+Quit" },
        r = { name = "+Refactor" },
        t = { name = "+Test", N = { name = "Neotest" } },
        -- stylua: ignore
        s = {
          name = "+Search",
          c = { function() require("utils.coding").cht() end, "Cheatsheets", },
          o = { function() require("utils.coding").stack_overflow() end, "Stack Overflow", },
        },
        u = { "+UserSettings" },
        -- v = { name = "+View" },
        w = { "+Window" },
        x = { "+Trouble" },
        c = {
          name = "+Code",
          g = { name = "Annotation" },
          x = {
            name = "Swap Next",
            f = "Function",
            p = "Parameter",
            c = "Class",
          },
          X = {
            name = "Swap Previous",
            f = "Function",
            p = "Parameter",
            c = "Class",
          },
        },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts.setup)
      wk.register(opts.defaults)
    end,
  },
}
