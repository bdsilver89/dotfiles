local opt = vim.opt
local g = vim.g

-- switch to powershell if available on windows
if vim.fn.has("win32") == 1 then
  require("config.util.terminal").setup("powershell")
end

-- disable providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- disable netrw
g.loaded_netrwPlugin = 1
g.loaded_netrw = 1

-- formatting setup
opt.formatexpr = "v:lua.vim.lsp.formatexpr()"
opt.formatexpr = "n"

opt.formatoptions = "jcroqlnt"

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
-- opt.whichwrap:append("<>[]hl")

-- diff settings
opt.diffopt = vim.list_extend(opt.diffopt:get(), { "algorithm:histogram", "linematch:60" })
