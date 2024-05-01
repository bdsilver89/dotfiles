vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.formatoptions = "jcroqlnt"
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep"
end
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.shortmess:append("sI")
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"
vim.opt.splitright = true
vim.opt.termguicolors = true
if not vim.g.vscode then
  vim.opt.timeoutlen = 300
end
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.opt.virtualedit = "block"

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
end
