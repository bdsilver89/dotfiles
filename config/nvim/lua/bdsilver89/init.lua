vim.uv = vim.uv or vim.loop

require("bdsilver89.config.options")
require("bdsilver89.config.keymaps")
require("bdsilver89.config.autocmds")
require("bdsilver89.config.lazy")

-- execute autocmds for post-lazy initialization
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigOptions", modeline = false })
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigKeymaps", modeline = false })
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigAutocmds", modeline = false })
