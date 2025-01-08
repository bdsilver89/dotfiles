local opt = vim.opt
local g = vim.g

-- disable providers
g.loaded_node_prodiver = 0
g.loaded_python3_prodiver = 0
g.loaded_perl_prodiver = 0
g.loaded_ruby_prodiver = 0

-- disable netrw
g.loaded_netrwPlugin = 1
g.loaded_netrw = 1

-- formatting setup
g.autoformat = nil

-- clipboard settings
opt.clipboard = "unnamed,unnamedplus"

-- line numbers
opt.number = true
opt.relativenumber = true
opt.cursorline = true

-- search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- splits
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- statusline settings
opt.laststatus = 3
opt.showmode = false
opt.ruler = false

-- folds
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "0"
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- text behavior
opt.fillchars = { eob = " " }
opt.list = true
opt.wrap = false
opt.virtualedit = "block"

-- decrease update time
opt.updatetime = 250

-- timeoutlen
opt.timeoutlen = 400

-- undofile
opt.undofile = true

-- shortmess
opt.shortmess:append("sI")

-- cursor wrap settings
opt.whichwrap:append("<>[]hl")
