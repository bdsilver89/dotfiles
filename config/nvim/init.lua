-- enable/disable use of nerdfont icons (will fall back on text icons)
vim.g.enable_icons = true

-- enable/disable material icon pack (must also enable nerdfont icons to work)
-- vim.g.enable_material_icons = true

-- enable/disable specific language support
vim.g.enable_lang_ansible = true
vim.g.enable_lang_bash = true
vim.g.enable_lang_c_cpp = true
vim.g.enable_lang_cmake = true
vim.g.enable_lang_docker = true
vim.g.enable_lang_go = true
vim.g.enable_lang_java = true
vim.g.enable_lang_json = true
vim.g.enable_lang_lua = true
vim.g.enable_lang_markdown = true
vim.g.enable_lang_python = true
vim.g.enable_lang_rust = true
vim.g.enable_lang_tailwind = true
vim.g.enable_lang_terraform = true
vim.g.enable_lang_typescript = true
vim.g.enable_lang_yaml = true
vim.g.enable_lang_zig = true

-- enable/disable mason as a package manager
-- disabling requires that tools (LSPs, debug adapters, formatters, linters)
-- are available in the system PATH
vim.g.enable_mason_packages = true

-- enable/disable codeium as an auto-completion option
-- vim.g.enable_completion_codeium = false

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- bootstrap config
require("config")
