return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "cmake", "make", "ninja" },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- "cmakelang",
        -- "cmakelint",
        "neocmakelsp",
      },
    },
  },
}
