return {
  { "folke/lazy.nvim", version = "*" },

  -- general lua utilities
  "nvim-lua/plenary.nvim",

  -- schema utilities for json and yaml lsp
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },

  -- markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org" },
    opts = {
      code = {
        sign = true,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = true,
        icons = {},
      },
    },
  },

  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "<leader>bd", function() MiniBufremove.delete(0, false) end, "Delete buffer", },

      -- Picker
      { "<leader><space>", "<cmd>Pick files<cr>", "Find files" },
      { "<leader>/", "<cmd>Pick grep_live<cr>", "Grep Live" },
      { "<leader>.", "<cmd>Pick grep<cr>", "Grep" },
      { "<leader>,", "<cmd>Pick buffers<cr>", "Buffers" },
      { "<leader>:", "<cmd>Pick commands<cr>", "Commands" },
      -- git
      { "<leader>gc", "<cmd>Pick git_commits<cr>", "Git Commits" },
      { "<leader>gb", "<cmd>Pick git_branches<cr>", "Git Branches" },
    },
    opts = {
      bufremove = {},
      extra = {},
      pick = {},
    },
    config = function(_, opts)
      for k, v in pairs(opts) do
        require("mini." .. k).setup(v)
      end
    end,
  },
}
