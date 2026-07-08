vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
})

require("mason").setup()
local mr = require("mason-registry")
mr.refresh(function()
  for _, tool in ipairs({
    "lua-language-server",
    "stylua",
    "jdtls",
  }) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end)
