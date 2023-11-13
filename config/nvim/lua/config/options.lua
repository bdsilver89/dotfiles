local opt = vim.opt

vim.g.mapleader = " "
vim.g.mapleaderlocal = "\\"

-- opt.autowrite = true -- only in lazy
opt.breakindent = true -- wrap indent to match line start
opt.clipboard = "unnamedplus" -- system clipboard
opt.cmdheight = 0 -- astro
opt.completeopt = { "menu", "menuone", "noselect" } -- options for insert-mode completion
-- opt.copyindent = true -- copy previous indentation for auto-indenting
opt.cursorline = true -- highlight current line of the cursor
opt.expandtab = true -- use spaces for tab
opt.formatoptions = {
  j = true, -- remove comment leader on join comments
  c = true, -- auto-wrap comments
  r = true, -- continue comments by default
  o = true, -- continue comment using 'o' or 'O'
  q = true, -- use gq to format comments
  l = true, -- auto break long lines
  n = true, -- recognize numbered lists
  t = true, -- auto wrap text
  -- a = false, -- auto-gq paragraphs
}
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  -- fold = "⸱",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldenable = true -- enable folds
opt.foldlevel = 99 -- set high fold level
-- foldlevelstart
opt.foldcolumn = "1"
if vim.fn.has("nvim-0.10") == 1 then
  opt.foldmethod = "expr"
  -- opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  opt.foldexpr = "v:lua.require('utils.ui.statuscolumn').foldexpr()"
else
  opt.foldmethod = "indent"
end
opt.grepformat = "%f:%l:%c:%m" -- change grepformat to display column as well
opt.grepprg = "rg --vimgrep" -- change grep to use rg program
-- history
opt.ignorecase = true -- case insensitive search
-- infercase
-- inccommand = "nosplit"
opt.laststatus = 3 -- global statusline
-- linebreak
-- list
-- listchars
opt.mouse = "a"
opt.number = true
-- preserveindent
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 4
-- opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({
  W = true, -- disable "written" message when writing a file
  I = true, -- disable vim intro message
  C = true, -- disable messages for ins-completion
  c = true, -- disable "pattern not found" messages
  s = true, -- disable "search hit BOTTOM" messages
})
opt.showmode = false -- disable showing mode in statusline
opt.showcmdloc = "statusline"
opt.showtabline = 2 -- always display tabline
opt.sidescrolloff = 8
opt.signcolumn = "yes" -- always show signcolumn
opt.smartcase = true -- case insensitive searching
-- smartindent
-- spelllang
opt.splitbelow = true -- splitting a new window below the current one
-- splitkeep
opt.splitright = true -- splitting a new window to the right of the current one
opt.tabstop = 2 -- number of spaces in a tab
opt.termguicolors = true -- enable 24-bit RGB colors
opt.timeoutlen = 300 -- shorten key timeout length
opt.undofile = true
opt.virtualedit = "block" --allow going past the end of line in visual block mode
-- wildmode
opt.winminwidth = 5
opt.wrap = false
-- writebackup

-- vim.opt.statuscolumn = "%!v:lua.require('utils.ui.statuscolumn').setup()"
-- vim.opt.statusline = "%!v:lua.require('utils.ui.statusline').setup()"
-- vim.opt.winbar = "%!v:lua.require('utils.ui.winbar').setup()"
-- vim.opt.tabline = "%!v:lua.require('utils.ui.tabline').setup()"
