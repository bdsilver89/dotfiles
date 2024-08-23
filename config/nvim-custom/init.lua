-- global vim options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- global PDE options
-- enable glyph icons, if false fallsback to text icons
vim.g.enable_icons = true

--- load config
require("config.lazy")
require("config.options")
require("config.autocmds")
require("config.keymaps")
