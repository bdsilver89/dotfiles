require("config.options")
require("config.lazy")
require("config.autocmds")
require("config.keymaps")

if vim.o.background == "dark" then
  vim.cmd.colorscheme(vim.g.colorscheme_dark)
else
  vim.cmd.colorscheme(vim.g.colorscheme_light)
end
