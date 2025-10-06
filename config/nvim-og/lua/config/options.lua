-- Leader key
vim.g.mapleader = " "
vim.g.mapllocaleader = " "

-- Providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0

-- Custom settings
vim.g.has_nerd_font = true

-- search
vim.o.ignorecase = true
vim.o.smartcase = true

-- ui
vim.o.cursorline = true
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.ruler = false
vim.o.relativenumber = true
vim.o.pumheight = 10
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.winborder = "none"
vim.o.wrap = false

-- behavior
vim.o.confirm = true
vim.o.mouse = "a"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.timeoutlen = 500
vim.o.undofile = true
vim.o.updatetime = 300
vim.o.virtualedit = "block"

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

if vim.fn.has("nvim-0.12") == 1 then
  vim.o.cmdheight = 0
  require("vim._extui").enable({})
end

-- Windows default to powershell instead of cmd
if vim.fn.has("win32") == 1 then
  local shell = (vim.fn.executable("pwsh") == 1) and "pwsh"
    or (vim.fn.executable("powershell") == 1) and "powershell"
    or ""

  if shell ~= "" then
    vim.o.shell = shell
    vim.o.shellcmdflag =
      "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='plaintext';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
    vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  else
    vim.notify("No powershell executable found", vim.log.levels.WARN)
  end
end
