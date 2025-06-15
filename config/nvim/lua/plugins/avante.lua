return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "zbirenbaum/copilot.lua",
  },
  keys = {
    { "<leader>aa", "<cmd>AvanteToggle<cr>", desc = "Avante Toggle" },
    { "<leader>aC", "<cmd>AvanteClear<cr>", desc = "Avante Clear" },
    { "<leader>am", "<cmd>AvanteModels<cr>", desc = "Avante Models" },
    { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "Avante Refresh" },
    { "<leader>ax", "<cmd>AvanteStop<cr>", desc = "Avante Stop" },
  },
  opts = {
    provider = "copilot",
    input = {
      provider = "snacks",
      provider_opts = {
        title = "Avante Input",
        icon = " ",
      },
    },
  },
}
