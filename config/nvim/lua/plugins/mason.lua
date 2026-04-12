vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
})

local mason_tools = {
  -- language serers
  "basedpyright",
  "bash-language-server",
  "jdtls",
  "json-lsp",
  "lua-language-server",
  "neocmakelsp",
  "yaml-language-server",

  -- formatters
  "shfmt",
  "stylua",

  -- linters

  -- debuggers
  "codelldb",
}

require("mason").setup()
local mason_registry = require("mason-registry")
for _, pkg in ipairs(mason_tools) do
  if not mason_registry.is_installed(pkg) then
    mason_registry.get_package(pkg):install()
  end
end
