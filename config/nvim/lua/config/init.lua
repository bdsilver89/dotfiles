vim.uv = vim.uv or vim.loop

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

-- execute remaining user autocmds
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigOptions", modeline = false })
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigKeymaps", modeline = false })
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigAutocmds", modeline = false })
