local icons = require("icons")

vim.g.mapleader = " "

local is_windows = vim.uv.os_uname().sysname == "Windows_NT"
local is_mac = vim.uv.os_uname().sysname == "Darwin"
local is_linux = vim.uv.os_uname().sysname == "Linux"
if is_mac then
  vim.g.projects_dir = vim.env.HOME .. "/Developer/projects"
elseif is_linux then
  vim.g.projects_dir = vim.env.HOME .. "/dev/projects"
elseif is_windows then
  vim.g.projects_dir = vim.env.HOME .. "/dev/projects"
end

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.o.linebreak = true
vim.o.wrap = false
vim.o.smartindent = true

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.laststatus = 3
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "0"
vim.o.list = true

vim.o.undofile = true

vim.o.pumheight = 10

-- vim.o.autocomplete = true
vim.o.completeopt = "menuone,noselect,fuzzy,noinsert,nosort"
vim.opt.shortmess:append({ w = true, s = true, c = true })
vim.opt.clipboard:append("unnamedplus")

vim.o.foldcolumn = "1"
vim.o.foldlevelstart = 99
vim.wo.foldtext = ""

-- vim.opt.diffopt:append("followwrap,vertical:context:99")

vim.opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  foldinner = " ",
  msgsep = "─",
}

require("vim._core.ui2").enable()

