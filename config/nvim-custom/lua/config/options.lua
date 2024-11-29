local opt = vim.opt

opt.backup = false
opt.breakindent = true
-- NOTE: WSL nvim slows down when synced to system clipboard, disable and handle in autocmd
-- opt.clipboard = ""
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "noselect" }
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.fillchars = "eob: "
opt.hlsearch = true
opt.ignorecase = true
opt.infercase = true
opt.laststatus = 3
opt.linebreak = true
opt.listchars = "tab:> ,extends:…,precedes:…,trail:-,nbsp:␣"
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.ruler = false
opt.scrolloff = 4
opt.shortmess:append({ c = true, C = true, s = true, I = true, w = true, W = true })
opt.showmode = false
-- opt.showtabline = 3
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.relativenumber = true
opt.timeoutlen = 400
opt.undofile = true
opt.updatetime = 250
opt.virtualedit = "block"
opt.winblend = 10
opt.wrap = false
opt.writebackup = false

vim.opt.statuscolumn = "%!v:lua.require'config.ui.statuscolumn'.eval()"
vim.opt.statusline = "%{%v:lua.require'config.ui.statusline'.eval()%}"
-- vim.opt.tabline = "%{%v:lua.require'config.ui.tabline'.eval()%}"
-- vim.opt.winbar = "%{%v:lua.require'config.ui.winbar'.eval()%}"

-- add mason-installed binaries to PATH
local is_windows = vim.fn.has("win32") ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH
