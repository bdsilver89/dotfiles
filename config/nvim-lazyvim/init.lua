-- enable/disable use of nerdfont icons (will fall back on text icons)
vim.g.enable_icons = true

-- enable/disable mason as a package manager
-- disabling requires that tools (LSPs, debug adapters, formatters, linters)
-- are available in the system PATH
vim.g.enable_mason_packages = false

-- enable/disable codeium as an auto-completion option
-- vim.g.enable_completion_codeium = false

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
