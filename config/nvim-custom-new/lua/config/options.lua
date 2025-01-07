local opt = vim.opt
local g = vim.g

-- leader key
g.mapleader = " "
g.maplocalleader = " "

-- nerd font options
g.has_nerd_font = true

-- disable providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- file picker options
g.picker = vim.fn.executable("fzf") == 1 and "fzf" or "telescope"

-- breakindent
opt.breakindent = true

-- line numbers
opt.number = true
opt.relativenumber = true

-- cursor and mouse
-- opt.colorcolumn = "100"
opt.cursorline = true
opt.laststatus = 3
opt.cmdheight = 0
opt.mouse = "a"

-- search
opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
opt.smartcase = true

-- splits
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- undo file
opt.undofile = true

-- clipboard
opt.clipboard = "unnamed,unnamedplus"

-- folds
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "1"
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- disable statusline components
opt.ruler = false
opt.showmode = false

-- text behavior
opt.fillchars = { eob = " " }
opt.list = true
opt.wrap = false
opt.virtualedit = "block"

-- decrease update time
opt.updatetime = 250

-- decrease mapped sequence wait time
opt.timeoutlen = 300

-- preview live substitutions
opt.inccommand = "split"

-- minimum number of screen lines to keep around cursor
opt.scrolloff = 8

-- signcolumn
opt.signcolumn = "yes"

-- nvim intro
opt.shortmess:append("sI")
