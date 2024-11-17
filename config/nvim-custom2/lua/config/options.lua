local opt = vim.opt

opt.backup = false
opt.breakindent = true
-- NOTE: WSL nvim slows down when synced to system clipboard, disable and handle in autocmd
-- opt.clipboard = ""
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "noselect" }
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.fillchars = "eob: "
opt.hlsearch = true
opt.ignorecase = true
opt.infercase = true
opt.laststatus = 3
opt.linebreak = true
opt.listchars = "tab:> ,extends:…,precedes:…,trail:-,nbsp:␣"
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.ruler = false
opt.scrolloff = 4
opt.shortmess:append({ c = true, C = true, s = true, I = true, w = true, W = true })
opt.showmode = false
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.relativenumber = true
opt.timeoutlen = 400
opt.undofile = true
opt.updatetime = 250
opt.virtualedit = "block"
opt.winblend = 10
opt.wrap = false
opt.writebackup = false

vim.opt.statusline = "%{%v:lua.require'config.ui.statusline'.eval()%}"
vim.opt.statuscolumn = "%!v:lua.require'config.ui.statuscolumn'.eval()"
-- vim.opt.winbar = "%{%v:lua.require'config.ui.winbar'.eval()%}"

-- add mason-installed binaries to PATH
local is_windows = vim.fn.has("win32") ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH

-- shell configuration
local shell = is_windows and "powershell" or vim.o.shell
vim.o.shell = shell or vim.o.shell
if shell == "pwsh" or "powershell" then
  if vim.fn.executable("pwsh") == 1 then
    vim.o.shell = "pwsh"
  elseif vim.fn.executable("powershell") == 1 then
    vim.o.shell = "powershell"
  else
    vim.notify("No powershell executable found", vim.log.levels.ERROR)
  end

  vim.o.shellcmdflag =
    "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='plaintext';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"

  vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'

  vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'

  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end
