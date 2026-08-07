vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true

vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.expandtab= true

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.laststatus = 3

vim.o.list = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.undofile = true
vim.o.wrap = false

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"

  local osc52 = require("vim.ui.clipboard.osc52")
  if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
      name = "wsl-osc52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = { "win32yank.exe", "-o", "--lf" },
        ["*"] = { "win32yank.exe", "-o", "--lf" },
      },
    }
  elseif vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
    vim.g.clipboard = {
      name = "OSC52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = function() return vim.split(vim.fn.getreg('"'), "\n") end,
        ["*"] = function() return vim.split(vim.fn.getreg('"'), "\n") end,
      },
    }
  end
end)
