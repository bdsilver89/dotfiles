vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.cmdheight = 0
vim.o.laststatus = 3
vim.o.undofile = true
vim.o.completeopt = "menu,popup,noselect"
vim.o.list = true

require("vim._core.ui2").enable({})
