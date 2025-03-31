local g = vim.g
local opt = vim.opt

-- leader key
g.mapleader = " "
g.maplocalleader = " "

-- disable providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- nerd font
g.has_nerd_font = true

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

opt.autowrite = true -- enable auto write
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- sync with sytem clipboard
opt.completeopt = "menuone,noselect,popup,fuzzy" -- completion behavior
opt.conceallevel = 2 -- hide some visual text components
opt.confirm = true -- confirm to save changes before exiting modified buffers
opt.cursorline = true -- enable highlighting current line
opt.diffopt = vim.list_extend(opt.diffopt:get(), { "algorithm:histogram", "linematch:60" })
opt.expandtab = true -- use spaces instead of tabs
-- opt.fillchars
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "0"
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.formatexpr = "v:lua.vim.lsp.formatexpr()" -- use LSP for formatter
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.ignorecase = true -- ignore case on search
opt.inccommand = "nosplit" -- preview incremental substitues
opt.jumpoptions = "view"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- wrap lines at convenient points
opt.list = true -- show some invisible characters
opt.mouse = "a" -- enable mouse mode
opt.number = true -- line number in numbercolumn
-- opt.pumblend = 10 -- popup blend
opt.pumheight = 10 -- maximum number of entries in a popup
opt.relativenumber = true -- relative line numbers
opt.ruler = false -- disable ruler
opt.scrolloff = 4 -- lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- round indent
opt.shiftwidth = 2 -- size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.smoothscroll = true
opt.sidescrolloff = 8 -- columns of context
opt.signcolumn = "yes" -- always show signcolumn to prevent it shifting text when it appears
opt.smartcase = true -- don't ignore case with capitals in search
opt.smartindent = true -- insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- split new windows below
opt.splitkeep = "screen"
opt.splitright = true -- split new windows to the right
opt.statuscolumn = "%=%l %s"
opt.tabstop = 2
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- lower the default to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- save sawp file and trigger CursorHold
opt.virtualedit = "block" -- allow cursor to move where there is no text in visual-block mode
opt.wildmode = "longest:full,full" -- command-line completion mode
-- opt.winblend = 10
opt.winminwidth = 5 -- minimum window width
opt.wrap = false -- disable line wrap

-- bigfile support
vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        if not path or not buf or vim.bo[buf].filetype == "bigfile" then
          return
        end
        if path ~= vim.api.nvim_buf_get_name(buf) then
          return
        end
        local size = vim.fn.getfsize(path)
        if size <= 0 then
          return
        end
        if size >= 1.5 * 1024 * 1024 then
          return "bigfile"
        end
        local lines = vim.api.nvim_buf_line_count(buf)
        return (size - lines) / lines > 1000 and "bigfile" or nil
      end,
    },
  },
})
