-- global vim options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- global PDE options
-- enable glyph icons, if false fallsback to text icons
vim.g.enable_icons = true

-- disable settings for large files
vim.g.bigfile_size = 1024 * 1024 * 1.5

--- enable use of plugins in lazy.nvim
vim.g.enable_lazy_nvim = true

-- load config
require("config")
