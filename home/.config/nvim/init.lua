vim.loader.enable()

require("options")
require("autocmds")
require("keymaps")
require("lsp")
-- require("winbar")
-- require("statusline")
require("statuscolumn")

vim.cmd.packadd("nvim.undotree")

require("vim._core.ui2").enable({})
