vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.opt.autoread = true
vim.opt.breakindent = true
vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.diffopt:append("linematch:60")
vim.opt.expandtab = true
vim.opt.fillchars = { eob = " " }
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.ignorecase = true
vim.opt.indentexpr = "v:lua.vim.treesitter.indentexpr()"
vim.opt.laststatus = 3
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.number = true
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 2
vim.opt.shortmess:append("cw")
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smoothscroll = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 250
vim.opt.wildmode = "longest:full,full"
vim.opt.wrap = false

vim.schedule(function()
  vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
  vim.cmd.colorscheme("catppuccin")
end)

