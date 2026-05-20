vim.g.mapleader = " "

vim.o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
vim.o.completeopt = "menu,menuone,noselect,popup"
vim.o.conceallevel = 2
vim.o.confirm = true
vim.o.foldlevel = 99
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.timeoutlen = vim.g.vscode and 1000 or 300
vim.o.undofile = true
vim.o.updatetime = 500
vim.o.wrap = false
vim.o.winborder = "rounded"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.signcolumn = "yes"

vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.diffopt:append("linematch:60,indent-heuristic,inline:char")
