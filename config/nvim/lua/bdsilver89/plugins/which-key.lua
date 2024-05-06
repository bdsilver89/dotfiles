return {
  -- show keybindings
  {
    "folke/which-key.nvim",
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      wk.register({
        ["<leader>b"] = "+buffer",
        ["<leader>c"] = "+code",
        ["<leader>d"] = "+debug",
        ["<leader>f"] = "+file/find",
        ["<leader>g"] = "+git",
        ["<leader>q"] = "+quit/session",
        ["<leader>s"] = "+search",
        ["<leader>t"] = "+term",
        ["<leader>w"] = "+windows",
        ["<leader>x"] = "+diagnostics/quickfix",
        ["<leader><tab>"] = "+tabs",
      })
    end,
  },
}
