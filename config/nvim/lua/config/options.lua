vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"      -- sync os/nvim clipboard
vim.opt.cmdheight = 0
vim.opt.cursorline = true              -- show active line
vim.opt.hlsearch = true                -- highlight search
vim.opt.ignorecase = true              -- ignore case when searching
vim.opt.inccommand = "split"           -- preview substitutions
vim.opt.laststatus = 3                 -- global statusline
vim.opt.list = true                    -- show whitespace
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.mouse = "a"                    -- enable mouse support
vim.opt.number = true                  -- show line number
vim.opt.pumblend = 10                  -- popup blend
vim.opt.pumheight = 10                 -- popup entries
vim.opt.relativenumber = true          -- show relative numbers
vim.opt.scrolloff = 10                 -- lines of context
vim.opt.shortmess:append("WIcC")
vim.opt.showmode = false               -- don't show mode, use statusline
vim.opt.sidescrolloff = 8              -- lines of context
vim.opt.signcolumn = "yes"             -- show signcolumn
vim.opt.smartcase = true               -- don't ignore seaarch case when capitals are used
vim.opt.splitbelow = true              -- change horizontal split direction
vim.opt.splitright = true              -- change vertical split direction
vim.opt.termguicolors = true           -- true colors
if not vim.g.vscode then
  vim.opt.timeoutlen = 300             -- decrease mapped sequence wait time for which-key
end
vim.opt.undofile = true                -- save undo history between sessions
vim.opt.updatetime = 250               -- decrease updatetime
vim.opt.virtualedit = "block"          -- used block editting mode
vim.opt.wildmode = "longest:full,full" -- command-line completion mode
vim.opt.winminwidth = 5                -- minimum window width
vim.opt.wrap = false                   -- do not wrap
