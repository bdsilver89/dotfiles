return {
  {
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
          adapter = "copilot",
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
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
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
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    ft = { "codecompanion" },
  },
}
