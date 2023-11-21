return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
  {
    "tpope/vim-fugitive",
    event = "LazyFile",
  },
  {
    "sindrets/diffview.nvim",
    enabled = false,
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
  },
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      {
        "folke/which-key.nvim",
        opts = {
          defaults = {
            ["<leader>m"] = "mark",
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>ma", function() require("harpoon.mark").add_file() end, desc = "Add file" },
      { "<leader>sm", "<cmd>Telescope harpoon marks<cr>", desc = "Harpoon marks" },
      { "<leader>mm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Menu" },
      { "<leader>m1", function() require("harpoon.ui").nav_file(1) end, desc = "Nav file 1" },
      { "<leader>m2", function() require("harpoon.ui").nav_file(2) end, desc = "Nav file 2" },
      { "<leader>m3", function() require("harpoon.ui").nav_file(3) end, desc = "Nav file 3" },
      { "<leader>m4", function() require("harpoon.ui").nav_file(4) end, desc = "Nav file 4" },
      { "<leader>m5", function() require("harpoon.ui").nav_file(5) end, desc = "Nav file 5" },
      { "<leader>m6", function() require("harpoon.ui").nav_file(6) end, desc = "Nav file 6" },
      { "<leader>m7", function() require("harpoon.ui").nav_file(7) end, desc = "Nav file 7" },
      { "<leader>m8", function() require("harpoon.ui").nav_file(8) end, desc = "Nav file 8" },
      { "<leader>m9", function() require("harpoon.ui").nav_file(9) end, desc = "Nav file 9" },
      { "<leader>sm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Menu" },
      { "<leader>mf", function()
        require("harpoon.term").sendCommand(1, "tmux-sessionizer\n")
        require("harpoon.term").gotoTerminal(1)
      end, desc = "Tmux sessionizer"},
    },
    opts = {
      global_settings = {
        save_on_toggle = true,
        enter_on_sendcmd = true,
        mark_branch = true,
      },
    },
    config = function(_, opts)
      require("harpoon").setup(opts)
      require("lazyvim.util").on_load("telescope.nvim", function()
        require("telescope").load_extension("harpoon")
      end)
    end,
  },
  {
    "nvim-neorg/neorg",
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
        -- ["core.dirman"] = {
        --   config = {
        --     workspaces = {
        --       notes = "~/notes",
        --     },
        --   },
        -- },
        ["core.integrations.nvim-cmp"] = {},
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp",
            name = "{Norg}",
          },
        },
      },
    },
  },
}
