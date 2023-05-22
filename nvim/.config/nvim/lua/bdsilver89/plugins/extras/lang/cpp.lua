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
