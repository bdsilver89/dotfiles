-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nerd font enable
vim.g.has_nerd_font = true

-- file picker
vim.g.picker = vim.fn.executable("fzf") == 1 and "fzf" or "telescope"

-- colorscheme
vim.g.colorscheme_dark = "catppuccin-mocha"
vim.g.colorscheme_light = "catppuccin-latte"
-- vim.g.colorscheme_dark = "tokyonight-night"
-- vim.g.colorscheme_light = "tokyonight-day"

-- load config
require("config")
