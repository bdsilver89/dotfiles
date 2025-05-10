-- Leader key
vim.g.mapleader = " "
vim.g.mapllocaleader = " "

-- Providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0

if vim.fn.has("win32") == 1 then
  require("utils").powershell_setup()
end

local opt = vim.opt

opt.autowrite = true -- enable auto write
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- sync with sytem clipboard
opt.completeopt = "menuone,noselect,popup,fuzzy" -- completion behavior
opt.conceallevel = 2 -- hide some visual text components
opt.confirm = true -- confirm to save changes before exiting modified buffers
opt.cursorline = true -- enable highlighting current line
opt.diffopt = vim.list_extend(opt.diffopt:get(), { "algorithm:histogram", "linematch:60" })
opt.expandtab = true -- use spaces instead of tabs
-- opt.fillchars
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "0"
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.formatexpr = "v:lua.vim.lsp.formatexpr()" -- use LSP for formatter
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.ignorecase = true -- ignore case on search
opt.inccommand = "nosplit" -- preview incremental substitues
opt.jumpoptions = "view"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- wrap lines at convenient points
opt.list = true -- show some invisible characters
opt.mouse = "a" -- enable mouse mode
opt.number = true -- line number in numbercolumn
-- opt.pumblend = 10 -- popup blend
opt.pumheight = 10 -- maximum number of entries in a popup
opt.relativenumber = true -- relative line numbers
opt.ruler = false -- disable ruler
opt.scrolloff = 4 -- lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.showmode = false -- disable mode
opt.shiftround = true -- round indent
opt.shiftwidth = 2 -- size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.smoothscroll = true
opt.sidescrolloff = 8 -- columns of context
opt.signcolumn = "yes" -- always show signcolumn to prevent it shifting text when it appears
opt.smartcase = true -- don't ignore case with capitals in search
opt.smartindent = true -- insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- split new windows below
opt.splitkeep = "screen"
opt.splitright = true -- split new windows to the right
opt.statuscolumn = "%=%l %s"
opt.tabstop = 2
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- lower the default to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- save sawp file and trigger CursorHold
opt.virtualedit = "block" -- allow cursor to move where there is no text in visual-block mode
opt.wildmode = "longest:full,full" -- command-line completion mode
opt.winborder = "rounded"
-- opt.winblend = 10
opt.winminwidth = 5 -- minimum window width
opt.wrap = false -- disable line wrap
