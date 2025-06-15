return {
  {
    "yetone/avante.nvim",
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
    -- keys = {
    --   { "<leader>aa", "<cmd>AvanteToggle<cr>", desc = "Avante Toggle" },
    --   { "<leader>ac", "<cmd>AvanteChat<cr>", desc = "Avante Chat" },
    --   { "<leader>aC", "<cmd>AvanteClear<cr>", desc = "Avante Clear" },
    --   { "<leader>am", "<cmd>AvanteModels<cr>", desc = "Avante Models" },
    --   { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "Avante Refresh" },
    --   { "<leader>ax", "<cmd>AvanteStop<cr>", desc = "Avante Stop" },
    -- },
    opts = {
      auto_suggestions_provider = "copilot",
      provider = "copilot",
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
  },

  {
    "blink.cmp",
    dependencies = {
      "Kaiser-Yang/blink-cmp-avante",
    },
    opts = {
      sources = {
        default = { "avante" },
        providers = {
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {},
          },
        },
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    ft = { "avante" },
  },
}
