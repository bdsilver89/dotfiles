vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/tpope/vim-dispatch",
  "https://github.com/tpope/vim-fugitive",

  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/folke/todo-comments.nvim",
  "https://github.com/folke/ts-comments.nvim",

  --- TODO: I don't know if we need these!
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
})

require("todo-comments").setup()
require("ts-comments").setup()
