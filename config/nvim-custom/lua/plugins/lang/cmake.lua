vim.g.enable_lang_cmake = vim.fn.executable("cmake") == 1

if not (vim.g.enable_lang_cmake ~= false) then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "cmake", "make", "ninja" },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "cmakelang",
        "cmakelint",
        "neocmakelsp",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        neocmake = {},
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        cmake = { "cmakelint" },
      },
    },
  },
}
