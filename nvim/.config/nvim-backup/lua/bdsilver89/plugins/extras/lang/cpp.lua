local function get_codelldb()
  local mason_registry = require("mason-registry")
  local codelldb = mason_registry.get_package("codelldb")
  local extension_path = codelldb:get_install_path() .. "/extension/"
  local codelldb_path = extension_path .. "adapter/codelldb"
  return codelldb_path
end

if not require("bdsilver89.config.lang").langs.cpp then
  return {}
end

return {
  -- NOTE: do not add c/cpp debugging configuration here! Rust configuration handles setup of codelldb debugger for all three languages
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "cpp", "c", "cmake" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {},
        cmake = {},
      },
    },
  },
}
