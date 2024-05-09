vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.markdown_recommended_style = 0

-- set to 'true' when nerd font icons should be used, otherwise uses text icons
vim.g.icons_enabled = true

-- set to 'true' when mason should be used to download LSPs/Linters/Formatters
-- otherwise system-wide installations are expected
vim.g.use_mason_lsp = true
vim.g.use_mason_dap = false
vim.g.use_mason_linter_formatter = true

-- set to 'true' to enable support for a given language (LSPs/Linters/Formatters/Etc)
vim.g.enable_c_cpp_support = true
vim.g.enable_lua_support = true

vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.inccommand = "split"
vim.opt.ignorecase =true
-- vim.opt.foldlevel = 99
vim.opt.formatoptions = "jcroqlnt"
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep"
end
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.shortmess:append("sI")
vim.opt.showcmdloc = "statusline"
vim.opt.showmode = false
vim.opt.showtabline = 2
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

vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
end

-- folding
vim.opt.foldlevel = 99

-- if vim.fn.has("nvim-0.9") == 1 then
--   vim.opt.foldtext = "v:lua.require'bdsilver89.utils'.folds.foldtext()"
-- end

if vim.fn.has("nvim-0.10") == 1 then
--   vim.opt.foldmethod = "expr"
--   -- vim.opt.foldexpr = "v:lua.require'bdsilver89.utils'.folds.foldexpr()"
--   vim.opt.foldtext = ""
--   vim.opt.fillchars = "fold: "
-- else
  vim.opt.foldmethod = "indent"
end
