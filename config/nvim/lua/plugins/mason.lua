vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
})

local mason_tools = {
  -- language serers
  "bash-language-server",
  "basedpyright",
  "jdtls",
  "lua-language-server",
  "neocmakelsp",

  -- formatters
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
