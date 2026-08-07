vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/jay-babu/mason-nvim-dap.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
})

local ensure_installed = require("lang").mason

-- Must run synchronously, and before plugins.lsp: mason.setup() prepends
-- mason/bin to PATH, and nothing here is on PATH otherwise. Deferring it means
-- vim.lsp.enable() cannot spawn mason-installed servers.
require("mason").setup()
-- Servers are declared explicitly in plugins.lsp; auto-enabling everything
-- mason installs also starts non-servers (e.g. `stylua --lsp`).
require("mason-lspconfig").setup({ automatic_enable = false })
require("mason-nvim-dap").setup()
require("mason-tool-installer").setup({
  ensure_installed = ensure_installed,
})
