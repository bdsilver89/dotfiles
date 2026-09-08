vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.autocomplete = true
vim.o.autocompletedelay = 100
vim.o.breakindent = true
vim.o.cmdheight = 0
vim.o.complete = ".,w,b,o"
vim.o.completeopt = "menu,menuone,noselect,fuzzy,preview"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.fillchars = "eob: "
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.shiftwidth = 2
vim.o.sidescrolloff = 8
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.virtualedit = "block"
vim.o.wrap = false

vim.schedule(function() vim.o.clipboard = "unnamedplus" end)

require("vim._core.ui2").enable({})
