local add = require("pack").add

add({
  {
    src = "catppuccin/nvim",
    module_name = "catppuccin",
    on_setup = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
})
