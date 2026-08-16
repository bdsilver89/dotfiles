vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.breakindent = true
vim.o.confirm = true
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.laststatus = 3
vim.o.list = true
vim.o.mouse = "a"
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10
vim.o.signcolumn = "yes"
vim.o.smartcase = 250
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.undofile = true
vim.o.updatetime = 250

vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.schedule(function() vim.o.clipboard = "unnamedplus" end)

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("textyank_post", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("n", "<c-h>", "<c-w><c-h>")
vim.keymap.set("n", "<c-j>", "<c-w><c-j>")
vim.keymap.set("n", "<c-k>", "<c-w><c-k>")
vim.keymap.set("n", "<c-l>", "<c-w><c-l>")

vim.keymap.set("t", "<esc>", "<c-\\><c-n>")

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

