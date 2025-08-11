-- Leader key
vim.g.mapleader = " "
vim.g.mapllocaleader = " "

-- Providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.has_nerd_font = true

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

vim.o.autowrite = true -- enable auto write
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)
vim.o.completeopt = "menuone,noselect,popup,fuzzy" -- completion behavior
vim.o.conceallevel = 2 -- hide some visual text components
vim.o.confirm = true -- confirm to save changes before exiting modified buffers
vim.o.cursorline = true -- enable highlighting current line
-- vim.o.diffopt = vim.list_extend(vim.opt.diffopt:get(), { "algorithm:histogram", "linematch:60" })
vim.o.expandtab = true -- use spaces instead of tabs
-- vim.o.fillchars
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldcolumn = "0"
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.o.formatexpr = "v:lua.vim.lsp.formatexpr()" -- use LSP for formatter
vim.o.formatoptions = "jcroqlnt"
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.ignorecase = true -- ignore case on search
vim.o.inccommand = "split" -- preview incremental substitues
vim.o.jumpoptions = "view"
vim.o.laststatus = 3 -- global statusline
vim.o.linebreak = true -- wrap lines at convenient points
vim.o.list = true -- show some invisible characters
vim.o.mouse = "a" -- enable mouse mode
vim.o.number = true -- line number in numbercolumn
-- vim.o.pumblend = 10 -- popup blend
vim.o.pumheight = 10 -- maximum number of entries in a popup
vim.o.relativenumber = true -- relative line numbers
vim.o.ruler = false -- disable ruler
vim.o.scrolloff = 4 -- lines of context
-- vim.o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.o.showmode = false -- disable mode
vim.o.shiftround = true -- round indent
vim.o.shiftwidth = 2 -- size of an indent
-- vim.o.shortmess:append({ W = true, I = true, c = true, C = true })
vim.o.smoothscroll = true
vim.o.sidescrolloff = 8 -- columns of context
vim.o.signcolumn = "yes" -- always show signcolumn to prevent it shifting text when it appears
vim.o.smartcase = true -- don't ignore case with capitals in search
vim.o.smartindent = true -- insert indents automatically
-- vim.o.spelllang = { "en" }
vim.o.splitbelow = true -- split new windows below
vim.o.splitkeep = "screen"
vim.o.splitright = true -- split new windows to the right
-- vim.o.statuscolumn = "%=%l %s"
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.timeoutlen = vim.g.vscode and 1000 or 300 -- lower the default to quickly trigger which-key
vim.o.undofile = true
vim.o.undolevels = 10000
vim.o.updatetime = 200 -- save sawp file and trigger CursorHold
vim.o.virtualedit = "block" -- allow cursor to move where there is no text in visual-block mode
vim.o.wildmode = "longest:full,full" -- command-line completion mode
vim.o.winborder = "rounded"
-- vim.o.winblend = 10
vim.o.winminwidth = 5 -- minimum window width
vim.o.wrap = false -- disable line wrap
