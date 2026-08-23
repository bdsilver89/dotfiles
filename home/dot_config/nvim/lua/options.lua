vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.o.breakindent = true
vim.o.cmdheight = 0
vim.o.completeopt = "menu,menuone,noselect,noinsert,popup,fuzzy"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.exrc = true
vim.o.fillchars = "eob: "
vim.o.foldlevel = 99
vim.o.foldmethod = "indent"
vim.o.formatoptions = "jcroqlnt"
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.laststatus = 3
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.mouse = "a"
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.shiftwidth = 2
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.wrap = false

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)
