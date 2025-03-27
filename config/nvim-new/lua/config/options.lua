local g = vim.g
local opt = vim.opt

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- switch to powershell if available on windows
if vim.fn.has("win32") == 1 then
  local function setup_powershell(shell)
    vim.o.shell = shell
    -- Setting shell command flags
    vim.o.shellcmdflag =
      "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='plaintext';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"

    -- Setting shell redirection
    vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'

    -- Setting shell pipe
    vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'

    -- Setting shell quote options
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  end

  if vim.fn.executable("pwsh") == 1 then
    setup_powershell("pwsh")
  elseif vim.fn.executable("powershell") == 1 then
    setup_powershell("powershell")
  else
    vim.notify("No powershell executable found", vim.log.levels.ERROR, { title = "Config" })
  end
end


-- disable providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- nerd font
vim.g.has_nerd_font = true

opt.clipboard = "unnamed,unnamedplus"
opt.conceallevel = 2
opt.completeopt = "menu,menuone,noselect"
opt.cursorline = true
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.formatexpr = "v:lua.vim.lsp.formatexpr()"
opt.laststatus = 3
opt.list = true
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.ruler = false
opt.shortmess:append("sI")
opt.showmode = false
opt.smartcase = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.undofile = true
opt.wrap = false

-- need to add mason install dir to path for LSP executables
-- WITHOUT loading mason.nvim
local is_windows = vim.fn.has("win32") == 1
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH

-- LSP
vim.lsp.enable({ "lua-language-server" })

-- diagnostics
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
  },
  severity_sort = true,
})
