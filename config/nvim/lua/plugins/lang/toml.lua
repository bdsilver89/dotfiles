return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "toml" } },
  },

  {
    "mason.nvim",
    opts = { ensure_installed = { "taplo" } },
  },
}
