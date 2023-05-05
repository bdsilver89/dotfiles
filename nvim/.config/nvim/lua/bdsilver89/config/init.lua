vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("bdsilver89.config.lazy")
require("bdsilver89.config.autocmds")
require("bdsilver89.config.keymaps")
require("bdsilver89.config.options")

vim.cmd.colorscheme("tokyonight")
