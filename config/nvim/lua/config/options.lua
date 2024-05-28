vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.large_buf = { size = 1024 * 500, lines = 10000 }

vim.g.enable_icons = true
vim.g.enable_mason_packages = true

local opt = vim.opt

opt.autowrite = true
opt.breakindent = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.cmdheight = 0
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.fillchars = {
  fold = " ",
  foldopen = vim.g.enable_icons and "" or "-",
  foldclose = vim.g.enable_icons and "" or "+",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldcolumn = "1"
opt.foldenable = true
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldmethod = "expr"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.formatoptions = "jrcoqlnt"
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep -uu"
  opt.grepformat = "%f:%l:%c:%m"
end
opt.hlsearch = true
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.laststatus = 3
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.shortmess:append({ s = true, I = true })
opt.showmode = false
opt.showtabline = 2
opt.signcolumn = "yes"
opt.smartcase = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
-- opt.termguicolors = true
opt.timeoutlen = vim.g.vscode and 1000 or 300
opt.undofile = true
opt.updatetime = 250
opt.virtualedit = "block"
opt.wrap = false
