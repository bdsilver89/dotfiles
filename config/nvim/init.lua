-- icon configuration
-- set to 'true' when a nerd font is installed
vim.g.enable_icons = true

-- mason configurtaion
-- set to 'true' to download LSPs, linters, and formatters from mason
-- setting to 'false' will force nvim-lspconfig to use system-installed LSPs instead
vim.g.enable_mason_packages = true

-- load config
require("config.lazy")
