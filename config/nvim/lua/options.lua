vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.wrap = false

vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.shiftround = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.undofile = true
vim.o.swapfile = false
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.mouse = "a"
vim.o.confirm = true

vim.o.sessionoptions = "buffers,curdir,folds,tabpages,winsize,winpos,localoptions"

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99

vim.o.winborder = "rounded"

vim.o.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  -- leadmultispace = "│ ",
}
vim.opt.fillchars = { eob = " " }

require("vim._core.ui2").enable({})

-- Clipboard lives in lua/clipboard.lua -- it needs per-platform detection.
