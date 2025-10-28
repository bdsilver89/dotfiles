local options = {
  laststatus = 3,
  mouse = "a",
  splitbelow = true,
  splitright = true,
  ruler = false,
  cmdheight = 0,
  number = true,
  relativenumber = true,
  cursorline = true,
  signcolumn = "yes",
  wrap = false,
  smartcase = true,
  undofile = true,
}

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

for name, value in pairs(options) do
  vim.opt[name] = value
end
