local opt = vim.opt
local cache_dir = os.getenv('HOME') .. '/.cache/nvim/'

opt.termguicolors = true

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.directory = cache_dir .. 'swap/'
opt.undodir = cache_dir .. 'undo/' 
opt.backupdir = cache_dir .. 'backup/'
opt.viewdir = cache_dir .. 'view/'
-- opt.spellfile = cache_dir .. 'spell/en.uft-8.add'

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

opt.startofline = false

opt.splitbelow = true
opt.splitright = true

opt.backspace = 'indent,eol,start'

opt.jumpoptions = 'stack'
opt.showmode = false

opt.scrolloff = 2
opt.sidescrolloff = 5
opt.foldlevelstart = 99
opt.ruler = false
opt.list = true
opt.showtabline = 0
opt.winwidth = 30
opt.winminwidth = 10
opt.pumheight = 10
opt.helpheight = 12
opt.previewheight = 12
opt.showcmd = false

opt.cmdheight = 0
opt.cmdwinheight = 5
opt.equalalways = false
opt.laststatus = 3
opt.display = 'lastline'

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

