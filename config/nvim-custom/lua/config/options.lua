local opt = vim.opt

opt.breakindent = true
opt.clipboard = "unnamed,unnamedplus"
opt.cmdheight = 0
opt.completeopt = { "menu", "menuone", "noselect" }
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldcolumn = "1"
opt.foldenable = true
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevelstart = 99
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep"
end
opt.hlsearch = true
opt.ignorecase = true
opt.inccommand = "split"
opt.infercase = true
opt.jumpoptions = "view"
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftround = true
opt.shortmess:append({ s = true, W = true, I = true, c = true, C = true })
opt.showmode = false
opt.smoothscroll = true
opt.signcolumn = "yes"
opt.smartcase = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.statuscolumn = [[%!v:lua.require'config.ui.statuscolumn'.eval()]]
-- opt.statusline = [[%!v:lua.require'config.ui.statusline'.eval()]]
opt.tabstop = 2
opt.termguicolors = true
opt.title = true
opt.timeoutlen = 300
opt.undofile = true
opt.updatetime = 300
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.wrap = false

vim.g.markdown_recommended_style = 0
