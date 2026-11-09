-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 9

-- Indentation
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Visual settings
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
-- vim.opt.showmatch = true
-- vim.opt.matchtime = 2
-- vim.opt.cmdheight = 0
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.winborder = "none"
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = "tab:» ,trail:·,nbsp:␣"
vim.opt.wrap = false

-- File handling
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.confirm = true

-- Behavior settings
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.virtualedit = "block"

-- Cursor settings

-- Folding settings
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"

-- Built-in netrw
vim.g.netrw_keepdir = 0
vim.g.netrw_localcopydircmd = "cp -r"

-- Command-line completion
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Diff view
vim.opt.fillchars:append("diff:╱")

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = {
      progress = "msg",
    },
  },
})
