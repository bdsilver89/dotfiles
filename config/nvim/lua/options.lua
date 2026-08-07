vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.breakindent = true
vim.o.confirm = true
vim.o.cmdheight = 0
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "indent"
vim.o.inccommand = "split"
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.shiftwidth = 2
vim.o.signcolumn = "yes"
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.winborder = "rounded"

vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  -- leadmultispace = "│ ",
}
vim.opt.fillchars = { eob = " " }

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

require("vim._core.ui2").enable({})

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = true,
  virtual_lines = false,
  float = {
    border = "rounded",
    source = "if_many",
  },
  underline = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})
