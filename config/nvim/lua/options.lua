vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.o.wrap = false
vim.o.smartindent = true

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.laststatus = 3
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "0"
vim.o.list = true

vim.o.undofile = true

vim.o.pumheight = 10

vim.o.autocomplete = true
vim.o.completeopt = "menuone,noselect,fuzzy,nosort"
vim.opt.shortmess:append("c")
vim.opt.clipboard:append("unnamedplus")

vim.o.foldlevel = 99

require("vim._core.ui2").enable()

