if vim.g.enable_lazy_nvim then
  require("config.lazy")
end
require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.ui.colorify").init()
