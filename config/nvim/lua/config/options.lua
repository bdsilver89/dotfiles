vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = false

vim.g.markdown_recommended_style = 0

local opt = vim.opt

opt.breakindent = true  -- break indent
opt.clipboard = "unnamedplus"  -- sync OS and Neovim clipboard
opt.conceallevel = 2  -- conceal some characters
opt.confirm = true  -- confirm to save on buffer modification
opt.cursorline = true  -- show line that cursor is on
opt.completeopt = "menu,menuone,noselect"  -- completion menu options
opt.expandtab = true  -- use spaces instead of tabs

opt.foldlevel = 99
if vim.fn.has("nvim-0.10") == 1 then
  -- TODO: replace with TS-aware folding
  opt.foldmethod = "indent"
else
  opt.foldmethod = "indent"
end

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep"  -- use rg, if available
end

opt.hlsearch = true  -- highlight search
opt.ignorecase = true  -- ignore case in searches
opt.inccommand = "split"  -- preview incremental substitutions
opt.laststatus = 3  -- single global statusline
opt.list = true  -- show whitespace characters
opt.mouse = "a"  -- enable mouse mode for all modes
opt.number = true  -- line numbers
opt.relativenumber = true  -- relative line numbers
opt.scrolloff = 10  -- minimum lines above/below of cursor
opt.shiftround = true  -- round indent
opt.shiftwidth = 2  -- indent size
opt.showmode = false  -- do not show mode
opt.sidescrolloff = 8  -- minimum columns left/right of cursor
opt.signcolumn = "yes"  -- enable sign column by default
opt.smartcase = true  -- do not ignore case with capitals
opt.smartindent = true  -- insert indents automatically
opt.splitbelow = true  -- split config
opt.splitright = true  -- split config
opt.splitkeep = "screen"  -- keep text on same line while splitting
opt.tabstop = 2  -- number of spaces for each tab
if not vim.g.vscode then
  opt.timeoutlen = 300  -- decrease mapped sequence wait time
end
opt.termguicolors = true  -- true color support
opt.undofile = true  -- save undo history
opt.updatetime = 250  -- decrease update time
opt.virtualedit = "block"  -- allow cursor to move in visual blocks where there is no text
opt.wildmode = "longest:full,full"  -- command-line completion
opt.winminwidth = 5  -- minimum window width
opt.wrap = false  -- disable text wrap

-- configure whitespace characters to nerd font characters
if vim.g.have_nerd_font then
  opt.listchars = {
    tab = '» ',
    trail = '·',
    nbsp = '␣'
  }
end

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
end
