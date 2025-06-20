return {
  "olimorris/codecompanion.nvim",
  cmd = {
    "CodeCompanion",
    "CodeCompanionChat",
    "CodeCompanionCmd",
    "CodeCompanionActions",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions" },
  },
  init = function()
    vim.cmd([[cab cc CodeCompanion]])
  end,
  opts = {
    strategies = {
      chat = {
        adapter = { name = "copilot", model = "claude-3.7-sonnet" },
        slash_commands = {
          ["buffer"] = {
            opts = {
              provider = "snacks",
            },
          },
          ["fetch"] = {
            opts = {
              provider = "snacks",
            },
          },
          ["file"] = {
            opts = {
              provider = "snacks",
            },
          },
          ["help"] = {
            opts = {
              provider = "snacks",
            },
          },
          ["image"] = {
            opts = {
              provider = "snacks",
            },
          },
          ["symbols"] = {
            opts = {
              provider = "snacks",
            },
          },
        },
        opts = {
          completion_provider = "blink",
        },
      },
      cmd = {
        adapter = { name = "copilot", model = "claude-3.7-sonnet" },
      },
      inline = {
        adapter = { name = "copilot", model = "claude-3.7-sonnet" },
      },
    },
    display = {
      action_palette = {
        provider = "snacks",
      },
      diff = {
        provider = "default",
      },
    },
  },
}
