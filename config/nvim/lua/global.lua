local global = {
  mapleader = " ",
  maplocalleader = "\\",
}

for name, value in pairs(global) do
  vim.g[name] = value
end
