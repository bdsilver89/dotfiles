require("config.options")
require("config.autocmds")
require("config.lazy")
vim.schedule(function()
  require("config.keymaps")
end)

if vim.o.background == "dark" then
  vim.cmd.colorscheme(vim.g.colorscheme_dark)
else
  vim.cmd.colorscheme(vim.g.colorscheme_light)
end
