local opt = vim.opt

opt.clipboard = "unnamed,unnamedplus"
opt.completeopt = { "menu", "noselect" }
opt.confirm = true
opt.cursorline = true
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.hlsearch = true
opt.ignorecase = true
opt.laststatus = 3
opt.list = true
opt.mouse = "a"
opt.number = true
opt.shortmess:append({ s = true, I = true })
opt.smartcase = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitright = true
-- opt.statuscolumn = ""
opt.statusline = "%!v:lua.require('config.ui.statusline')()"
opt.relativenumber = true
opt.timeoutlen = 400
opt.undofile = true
opt.updatetime = 250
opt.virtualedit = "block"

-- add mason-installed binaries to PATH
local is_windows = vim.fn.has("win32") ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH
