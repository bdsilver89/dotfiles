require("global")
require("options")

if vim.g.vscode then
  require("vscode_config")
else
  require("keymaps")
  require("autocmds")
  require("statusline")
  require("lsp")
  require("plugins")
end
