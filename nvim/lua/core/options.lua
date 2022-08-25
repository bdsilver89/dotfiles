local opt = vim.opt
local wo = vim.wo
local cache_dir = os.getenv('HOME') .. '/.cache/nvim/'

-- vim.scriptencoding = 'utf-8'
-- opt.encoding = 'utf-8'
-- opt.fileencoding = 'utf-8'

-- wo.number = true
-- wo.relativenumber = true

-- opt.title = true
-- opt.autoindent = true
-- opt.smartindent = true
-- opt.hlsearch = true
-- opt.backup = false
-- opt.showcmd = true
-- opt.cmdheight = 1
-- opt.laststatus = 2
-- opt.scrolloff = 10
-- opt.shell = 'zsh'
-- opt.backupskip = { '/tmp/*', '/private/tmp/*' }
-- opt.inccommand = 'split'
-- opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
-- opt.smarttab = true
-- opt.breakindent = true
-- opt.shiftwidth = 2
-- opt.tabstop = 2
-- opt.wrap = false -- No Wrap lines
-- opt.backspace = { 'start', 'eol', 'indent' }
-- opt.path:append { '**' } -- Finding files - Search down into subfolders
-- opt.wildignore:append { '*/node_modules/*' }

-- opt.cursorline = true
-- opt.termguicolors = true
-- opt.winblend = 0
-- opt.wildoptions = 'pum'
-- opt.pumblend = 5
-- opt.background = 'dark'

-- other config.....

opt.termguicolors = true
opt.mouse = 'nv'
opt.errorbells = true
opt.visualbell = true
opt.hidden = true
opt.fileformats = 'unix,mac,dos'
opt.magic = true
opt.virtualedit = 'block'
opt.encoding = 'utf-8'
opt.viewoptions = 'folds,cursor,curdir,slash,unix'
opt.sessionoptions = 'curdir,help,tabpages,winsize'
opt.clipboard = 'unnamedplus'
opt.wildignorecase = true
opt.wildignore =
  '.git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**'
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.directory = cache_dir .. 'swag/'
opt.undodir = cache_dir .. 'undo/'
opt.backupdir = cache_dir .. 'backup/'
opt.viewdir = cache_dir .. 'view/'
opt.spellfile = cache_dir .. 'spell/en.uft-8.add'
opt.history = 2000
opt.shada = "!,'300,<50,@100,s10,h"
opt.backupskip = '/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim'
opt.smarttab = true
opt.shiftround = true
opt.timeout = true
opt.ttimeout = true
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.updatetime = 100
opt.redrawtime = 1500
opt.ignorecase = true
opt.smartcase = true
opt.infercase = true
opt.incsearch = true
opt.wrapscan = true
opt.complete = '.,w,b,k'
opt.inccommand = 'nosplit'
opt.grepformat = '%f:%l:%c:%m'
opt.grepprg = 'rg --hidden --vimgrep --smart-case --'
opt.breakat = [[\ \	;:,!?]]
opt.startofline = false
opt.whichwrap = 'h,l,<,>,[,],~'
opt.splitbelow = true
opt.splitright = true
opt.switchbuf = 'useopen'
opt.backspace = 'indent,eol,start'
opt.diffopt = 'filler,iwhite,internal,algorithm:patience'
opt.completeopt = 'menu,menuone,noselect'
opt.jumpoptions = 'stack'
opt.showmode = false
opt.shortmess = 'aoOTIcF'
opt.scrolloff = 2
opt.sidescrolloff = 5
opt.foldlevelstart = 99
opt.ruler = false
opt.list = true
opt.showtabline = 0
opt.winwidth = 30
opt.winminwidth = 10
opt.pumheight = 15
opt.helpheight = 12
opt.previewheight = 12
opt.showcmd = false

-- just for nightly
opt.cmdheight = 1
opt.cmdwinheight = 5
opt.equalalways = false
opt.laststatus = 3
opt.display = 'lastline'
opt.showbreak = '↳  '
opt.listchars = 'tab:»·,nbsp:+,trail:·,extends:→,precedes:←'
opt.pumblend = 10
opt.winblend = 10

opt.undofile = true
opt.synmaxcol = 2500
opt.formatoptions = '1jcroql'
opt.textwidth = 80
opt.expandtab = true
opt.autoindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = -1
opt.breakindentopt = 'shift:2,min:20'
opt.wrap = false
opt.linebreak = true
opt.number = true
opt.colorcolumn = '100'
opt.foldenable = true
opt.signcolumn = 'yes'
opt.conceallevel = 2
opt.concealcursor = 'niv'

if vim.loop.os_uname().sysname == 'Darwin' then
  vim.g.clipboard = {
    name = 'macOS-clipboard',
    copy = {
      ['+'] = 'pbcopy',
      ['*'] = 'pbcopy',
    },
    paste = {
      ['+'] = 'pbpaste',
      ['*'] = 'pbpaste',
    },
    cache_enabled = 0,
  }
  vim.g.python_host_prog = '/usr/bin/python'
  vim.g.python3_host_prog = '/usr/local/bin/python3'
end

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = '*',
  command = "set nopaste"
})

-- Add asterisks in block comments
vim.opt.formatoptions:append { 'r' }

