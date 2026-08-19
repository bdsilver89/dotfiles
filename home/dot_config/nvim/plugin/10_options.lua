vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.mouse = "a"
vim.o.undofile = true

vim.o.breakindent = true
vim.o.colorcolumn = "+1"
vim.o.cursorline = true
vim.o.linebreak = true
vim.o.list = true
vim.o.number = true
vim.o.pumborder = "single"
vim.o.pumheight = 10
vim.o.pummaxwidth = 100
vim.o.shortmess = "CFOSWaco"
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.o.winborder = "single"
vim.o.wrap = false

vim.o.fillchars = "eob: "
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"

vim.o.foldlevel = 99
vim.o.foldmethod = "indent"

vim.o.autoindent = true
vim.o.expandtab = true
vim.o.formatoptions = "rqnl1j"
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.shiftwidth = 2
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.spelloptions = "camel"
vim.o.tabstop = 2
vim.o.virtualedit = "block"

vim.o.complete = ".,w,b,kspell"
vim.o.completeopt = "menuone,noselect,fuzzy,nosort"
vim.o.completetimeout = 100

local f = function() vim.cmd("setlocal formatoptions-=c formatoptions-=o") end
Config.new_autocmd("FileType", nil, f, "Proper formatoptions")

local diagnostic_opts = {
  signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },
  underline = { severity = { min = "HINT", max = "ERROR" } },
  virtual_lines = false,
  virtual_text = {
    current_line = true,
    severity = { min = "ERROR", max = "ERROR" },
  },
  update_in_insert = false,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  }
}

Config.later(function() vim.diagnostic.config(diagnostic_opts) end)
