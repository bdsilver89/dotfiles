vim.pack.add({
  { src = "https://github.com/Everblush/nvim", name = "everblush" },
  "https://github.com/neanias/everforest-nvim",
  "http://github.com/ellisonleao/gruvbox.nvim",
})

require("gruvbox").setup()
require("everforest").setup({})

-- vim.cmd.colorscheme("everblush")
-- vim.cmd.colorscheme("everforest")
vim.cmd.colorscheme("gruvbox")
