return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
        lazy = true,
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        lazy = true,
        enabled = vim.fn.executable("make") == 1,
        build = "make",
      },
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      -- TODO: more
      { "<leader>/", "<cmd>Telescope live_grep<cr>", "Grep" },
      { "<leader>:", "<cmd>Telescope history<cr>", "Command history" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>", "Find files" },
    },
    opts = function()
      return {
        defaults = {
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              vertical = {
                mirror = false,
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)

      -- TODO: extensions
    end,
  },
}
