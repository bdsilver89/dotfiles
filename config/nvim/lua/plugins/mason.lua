return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      "lua-language-server",
      "neocmakelsp",
      "stylua",
    },
  },
  config = function(_, opts)
    require("mason").setup()
    local mr = require("mason-registry")
    mr.refresh(function()
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end)
  end,
}
