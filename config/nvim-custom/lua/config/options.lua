vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.enable_icons = true
vim.g.enable_mason_packages = true

vim.g.statuscolumn_folds_open = false
vim.g.statuscolumn_folds_githl = false

local opt = vim.opt

opt.autowrite = true
opt.breakindent = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.cmdheight = 0
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
-- expandtab
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldcolumn = "1"
opt.foldenable = true
opt.foldlevel = 99
opt.foldexpr = "v:lua.require'config.ui'.foldexpr()"
opt.foldmethod = "expr"
opt.foldtext = ""
-- formatexpr
-- formatoptions
-- grepformat
-- grepprg
opt.hlsearch = true
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.laststatus = 3
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 4
-- sessionoptions
-- shiftround
-- shiftwidth
-- shortmess
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.spelllang = { "en" }
opt.spelloptions:append("noplainbuffer")
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.statuscolumn = [[%!v:lua.require'config.ui'.statuscolumn()]]
opt.termguicolors = true
opt.timeoutlen = vim.g.vscode and 1000 or 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 250
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.wrap = false

vim.g.markdown_recommended_style = 0
