vim.opt.guicursor = ''

vim.mouse = 'a'

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true
vim.opt.errorbells = false

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append('@-@')

vim.opt.completeopt = 'menuone,noselect'

vim.opt.updatetime = 50

vim.opt.colorcolumn = '80'

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
