local add = require("pack").add

local tools = {
  "basedpyright",
  "bash-language-server",
  "codelldb",
  "debugpy",
  "docker-compose-language-server",
  "docker-language-server",
  "dprint",
  "html-lsp",
  "jdtls",
  "js-debug-adapter",
  "json-lsp",
  "lemminx",
  "lua-language-server",
  "neocmakelsp",
  "palantir-java-format",
  "ruff",
  "shfmt",
  "sqlfluff",
  "stylua",
  "tailwindcss-language-server",
  "taplo",
  "terraform-ls",
  "tsgo",
  "vtsls", --TODO: remove for tsgo
  "yaml-language-server",
}

add({
  {
    src = "mason-org/mason.nvim",
    on_setup = function()
      local registry = require("mason-registry")

      local function install_missing()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end

      if registry.refresh then
        registry.refresh(install_missing)
      else
        install_missing()
      end
    end,
  },
})
