if vim.loader then
  vim.loader.enable()
end

vim.uv = vim.uv or vim.loop

vim.g.is_win = ((vim.fn.has("win32") == 1) or (vim.fn.has("win64") == 1)) and true or false
vim.g.is_mac = (vim.fn.has("macunix") == 1) and true or false
vim.g.is_linux = (vim.fn.has("unix") == 1) and true or false

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
