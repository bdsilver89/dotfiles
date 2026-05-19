require("plugins.utils")
require("plugins.colorschemes")
require("plugins.mason")
require("plugins.treesitter")
require("plugins.markdown")
require("plugins.blink")
require("plugins.oil")
require("plugins.git")
require("plugins.snacks")
require("plugins.whichkey")
require("plugins.grug")
require("plugins.lsp")
require("plugins.conform")
require("plugins.dap")

vim.pack.add({
  "https://github.com/mfussenegger/nvim-lint",
  "https://github.com/yorickpeterse/nvim-jump", -- TODO: replace with folke
  "https://github.com/folke/trouble.nvim",
  "https://github.com/gbprod/yanky.nvim",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/akinsho/toggleterm.nvim",
  "https://github.com/rebelot/heirline.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/akinsho/bufferline.nvim",
  "https://github.com/fgheng/winbar.nvim",
})
