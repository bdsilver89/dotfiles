return {
  "yetone/avante.nvim",
  enabled = false,
  build = vim.fn.has("win32") == 1 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  cmd = {
    "AvanteAsk",
    "AvanteBuild",
    "AvanteEdit",
    "AvanteRefresh",
    "AvanteSwitchProvider",
    "AvanteShowRepoMap",
    "AvanteModels",
    "AvanteChat",
    "AvanteToggle",
    "AvanteClear",
    "AvanteFocus",
    "AvanteStop",
  },
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "zbirenbaum/copilot.lua",
  },
  keys = {
    { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Avante Ask" },
    { "<leader>ac", "<cmd>AvanteChat<cr>", desc = "Avante Chat" },
    { "<leader>aC", "<cmd>AvanteClear<cr>", desc = "Avante Clear" },
    { "<leader>am", "<cmd>AvanteModels<cr>", desc = "Avante Models" },
    { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "Avante Refresh" },
    { "<leader>ax", "<cmd>AvanteStop<cr>", desc = "Avante Stop" },
  },
  opts = {
    auto_suggestions_provider = "copilot",
    provider = "copilot",
    providers = {
      copilot = {
        model = "claude-3.7-sonnet",
      },
    },
    input = {
      provider = "snacks",
      provider_opts = {
        title = "Avante Input",
        icon = " ",
      },
    },
    selector = {
      provider = "snacks",
    },
  },
}
