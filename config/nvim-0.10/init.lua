pcall(vim.loader.enable)

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nerd font enable
vim.g.has_nerd_font = true

-- file picker ("telescope", "fzf", "snacks")
vim.g.picker = "snacks"

-- completion engine ("nvim-cmp", "blink.cmp", "mini")
vim.g.completion_engine = "blink.cmp"

-- statusline ("lualine", "mini")
vim.g.statusline = "mini"

-- bufferline ("bufferline", "mini")
vim.g.buffer = "mini"

-- colorscheme
vim.g.colorscheme_dark = "catppuccin-mocha"
vim.g.colorscheme_light = "catppuccin-latte"

-- load config
require("config")
