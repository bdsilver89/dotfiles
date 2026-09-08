local ensure_installed = {
  "bash-language-server",
  "basedpyright",
  "jdtls",
  "lua-language-server",
  "ruff",
  "stylua",
}

require("mason").setup({})

local mr = require("mason-registry")
mr.refresh(function()
  for _, tool in ipairs(ensure_installed) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end)
