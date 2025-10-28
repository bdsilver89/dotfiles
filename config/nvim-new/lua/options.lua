local options = {
  cmdheight = 0,
  cursorline = true,
  hlsearch = true,
  ignorecase = true,
  laststatus = 3,
  mouse = "a",
  number = true,
  relativenumber = true,
  ruler = false,
  signcolumn = "yes",
  smartcase = true,
  splitbelow = true,
  splitright = true,
  undofile = true,
  wrap = false,
}

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

for name, value in pairs(options) do
  vim.opt[name] = value
end
