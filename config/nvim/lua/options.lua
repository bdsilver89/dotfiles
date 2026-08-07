vim.g.mapleader = " "

vim.o.breakindent = true
vim.o.cmdheight = 0
vim.o.completeopt = "menu,menuone,noselect,preview"
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.updatetime = 200
vim.o.winborder = "rounded"
vim.o.wrap = false

vim.opt.fillchars = { eob = " " }
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "…",
  -- precedes = '〈',
}

require("vim._core.ui2").enable({})
