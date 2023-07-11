return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      setup = {
        show_help = true,
        plugins = { spelling = true },
        triggers = "auto",
      },
      defaults =  {
        prefix = "<leader>",
        mode = { "n", "v" },
        ["b"] = { name = "+Buffer" },
        ["f"] = { name = "+Find" },
        ["g"] = { name = "+Git", h = { name = "Hunk" }, t = { name = "Toggle" } },
        ["j"] = { name = "+Jump" },
        ["s"] = { name = "+Search" },
        ["q"] = { name = "+Quit" },
        ["u"] = { name = "+UserSetting" },
        ["w"] = { name = "+Window" },
        ["x"] = { name = "+Trouble" },
        ["<tab>"] = { name = "+Tabs" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts.setup)
      wk.register(opts.defaults)
    end,
  },
}
