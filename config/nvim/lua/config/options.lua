local opt = vim.opt

opt.autowrite = true
opt.breakindent = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.cmdheight = 0
opt.cursorline = true
opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldcolumn = "1"
opt.foldenable = true
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
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 10
opt.shortmess:append("WIcC")
opt.showmode = true
opt.signcolumn = "yes"
opt.smartcase = true
opt.splitbelow = true
opt.splitright = true
opt.statuscolumn = [[%!v:lua.require'config.ui'.statuscolumn()]]
-- opt.statusline = [[%!v:lua.require'config.ui'.statusline()]]
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.updatetime = 250
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
-- opt.winbar = [[%!v:lua.require'config.ui'.winbar()]]

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
  opt.foldmethod = "expr"
  opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
else
  opt.foldmethod = "indent"
end
