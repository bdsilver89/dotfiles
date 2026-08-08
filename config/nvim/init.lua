-- Neovim 0.12+. vim.pack for plugins, native LSP, no distro.

require("options")

-- Before the PATH narrowing: this is the one thing that needs a Windows binary.
require("clipboard").setup()

require("wslpath").without_windows(function()
  require("autocmds")
  require("plugins")
  require("keymaps")
  require("editor")
  require("lsp")
  require("lang")
end)
