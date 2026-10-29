vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.expandtab = true

vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"

vim.o.laststatus = 3
vim.o.showmode = false
vim.o.ruler = false

vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = "screen"

vim.o.inccommand = "nosplit"

vim.o.wrap = false
vim.o.linebreak = true
vim.o.breakindent = true

vim.o.foldenable = true
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

vim.o.virtualedit = "block"

vim.o.updatetime = 250

vim.o.confirm = true

vim.schedule(function() vim.o.clipboard = "unnamedplus" end)
