if vim.loader and vim.loader.enable then
  vim.loader.enable()
end

require("config.options")
require("config.lazy")
require("config.autocmds")
require("config.keymaps")
require("config.lsp")
