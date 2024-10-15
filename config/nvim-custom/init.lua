-------------------------------------------------------------------------------
-- global vim options
-------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- disable loaders
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- enable glyph icons, if false fallsback to text icons
vim.g.enable_icons = true
vim.g.enable_mini_icons = false
vim.g.enable_nvim_devicons = true

-- disable settings for large files
vim.g.bigfile_size = 1024 * 1024 * 1.5

--- enable use of plugins in lazy.nvim
vim.g.enable_lazy_nvim = true

-------------------------------------------------------------------------------
-- load config
-------------------------------------------------------------------------------
if vim.g.enable_lazy_nvim then
  require("config.lazy")
end
require("config.options")
require("config.autocmds")

vim.schedule(function()
  require("config.keymaps")
  require("config.ui.colorify").init()
end)
