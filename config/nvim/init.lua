-------------------------------------------------------------------------------
-- user customizable flags
-------------------------------------------------------------------------------
-- enable/disable use of nerdfont icons (will fall back on text icons)
vim.g.enable_icons = true

-- enable/disable specific language support
vim.g.enable_lang_c_cpp = true
vim.g.enable_lang_cmake = true
vim.g.enable_lang_lua = true
vim.g.enable_lang_markdown = true

-- enable/disable mason as a package manager
-- disabling requires that tools (LSPs, debug adapters, formatters, linters)
-- are available in the system PATH
vim.g.enable_mason_packages = true

-- enable/disable codeium as an auto-completion option
vim.g.enable_completion_codeium = false

-- map leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-------------------------------------------------------------------------------
-- config load
-------------------------------------------------------------------------------
require("config")
