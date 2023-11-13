return {
  {
    "nvim-neorg/neorg",
    enabled = false,
    ft = { "norg" },
    cmd = "Neorg",
    build = ":Neorg sync-parsers",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-cmp",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.summary"] = {},
        ["core.integrations.nvim-cmp"] = {},
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp",
            name = "{Neorg}",
          },
        },
      },
    },
  },
}
