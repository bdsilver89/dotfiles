pcall(vim.loader.enable)

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nerd font enable
vim.g.has_nerd_font = true

-- file picker
vim.g.picker = "snacks"

-- completion engine
-- vim.g.completion_engine = vim.fn.executable("cargo") == 1 and "blink.cmp" or "nvim-cmp"
vim.g.completion_engine = "nvim-cmp"

-- colorscheme
vim.g.colorscheme_dark = "catppuccin-mocha"
vim.g.colorscheme_light = "catppuccin-latte"

-- load config
require("config")
