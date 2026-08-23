vim.loader.enable()

require("options")
require("keymaps")
require("commands")
require("autocmds")
require("statuscolumn")
require("statusline")
require("winbar")
require("tabufline")
require("lsp")

vim.cmd.packadd("nvim.undotree")

require("vim._core.ui2").enable()
