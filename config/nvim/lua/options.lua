local opts = {
  cmdheight = 0,
  cursorline = true,
  hlsearch = true,
  ignorecase = true,
  inccommand = "nosplit",
  laststatus = 3,
  list = true,
  mouse = "a",
  number = true,
  relativenumber = true,
  ruler = false,
  scrolloff = 8,
  showmode = false,
  signcolumn = "yes",
  smartcase = true,
  splitbelow = true,
  splitright = true,
  termguicolors = true,
  undofile = true,
  winborder = "rounded",
  wrap = false,
}

for opt, value in pairs(opts) do
  vim.o[opt] = value
end

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

require("vim._extui").enable({
  enable = true,
  msg = {
    target = "cmd",
    timeout = 4000,
  },
})
