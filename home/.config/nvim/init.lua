vim.loader.enable()

require("options")
require("autocmds")
require("keymaps")
require("lsp")

vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")

require("vim._core.ui2").enable({})
