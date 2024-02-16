return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  {
    "echasnovski/mini.comment",
    enabled = false,
  },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = function()
      local commentstring_avail, commentstring = pcall(require, "ts_comment_commentstring.integrations.comment_nvim")
      return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    -- keys = {
    --   { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
    --   { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
    --   { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
    --   { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
    -- },
    -- init = function()
    --   vim.g.tmux_navigator_no_mappings = 1
    -- end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      source_selector = {
        winbar = true,
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
      },
    },
  },
  -- {
  --   "ThePrimeagen/harpoon",
  --   branch = "master",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-telescope/telescope.nvim",
  --     {
  --       "folke/which-key.nvim",
  --       opts = {
  --         defaults = {
  --           ["<leader>m"] = "mark",
  --         },
  --       },
  --     },
  --   },
  --   -- stylua: ignore
  --   keys = {
  --     { "<leader>ma", function() require("harpoon.mark").add_file() end, desc = "Add file" },
  --     { "<leader>sm", "<cmd>Telescope harpoon marks<cr>", desc = "Harpoon marks" },
  --     { "<leader>mm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Menu" },
  --     { "<leader>m1", function() require("harpoon"):list():select(1) end, desc = "Nav file 1" },
  --     { "<leader>m2", function() require("harpoon"):list():select(2) end, desc = "Nav file 2" },
  --     { "<leader>m3", function() require("harpoon"):list():select(3) end, desc = "Nav file 3" },
  --     { "<leader>m4", function() require("harpoon"):list():select(4) end, desc = "Nav file 4" },
  --     { "<leader>m5", function() require("harpoon"):list():select(5) end, desc = "Nav file 5" },
  --     { "<leader>m6", function() require("harpoon"):list():select(6) end, desc = "Nav file 6" },
  --     { "<leader>m7", function() require("harpoon"):list():select(7) end, desc = "Nav file 7" },
  --     { "<leader>m8", function() require("harpoon"):list():select(8) end, desc = "Nav file 8" },
  --     { "<leader>m9", function() require("harpoon"):list():select(9) end, desc = "Nav file 9" },
  --     { "<leader>sm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Menu" },
  --     { "<leader>mf", function()
  --       require("harpoon.term").sendCommand(1, "tmux-sessionizer\n")
  --       require("harpoon.term").gotoTerminal(1)
  --     end, desc = "Tmux sessionizer"},
  --   },
  --   opts = {
  --     global_settings = {
  --       save_on_toggle = true,
  --       enter_on_sendcmd = true,
  --       mark_branch = true,
  --     },
  --   },
  --   config = function(_, opts)
  --     require("harpoon").setup(opts)
  --     require("lazyvim.util").on_load("telescope.nvim", function()
  --       require("telescope").load_extension("harpoon")
  --     end)
  --   end,
  -- },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      --     "nvim-lua/plenary.nvim",
      --     "nvim-telescope/telescope.nvim",
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
      { "<leader>sm", "<cmd>Telescope harpoon marks<cr>", desc = "Harpoon marks" },
      { "<leader>m1", function() require("harpoon"):list():select(1) end, desc = "Harpoon file #1" },
      { "<leader>m2", function() require("harpoon"):list():select(2) end, desc = "Harpoon file #2" },
      { "<leader>m3", function() require("harpoon"):list():select(3) end, desc = "Harpoon file #3" },
      { "<leader>m4", function() require("harpoon"):list():select(4) end, desc = "Harpoon file #4" },
      { "<leader>m5", function() require("harpoon"):list():select(5) end, desc = "Harpoon file #5" },
      { "<leader>m6", function() require("harpoon"):list():select(6) end, desc = "Harpoon file #6" },
      { "<leader>m7", function() require("harpoon"):list():select(7) end, desc = "Harpoon file #7" },
      { "<leader>m8", function() require("harpoon"):list():select(8) end, desc = "Harpoon file #8" },
      { "<leader>m9", function() require("harpoon"):list():select(9) end, desc = "Harpoon file #9" },
      { "<leader>ma", function() require("harpoon"):list():append() end, desc = "Harpoon add" },
      { "<leader>mm", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
    },
  },
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    -- stylua: ignore
    keys = {
      { "<leader>e", function() require("oil").toggle_float() end, desc = "Oil" },
    },
    opts = {
      win_opts = {
        signcolumn = "number",
      },
    },
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("oil").open(vim.fn.argv(0))
        end
      end
    end,
    config = true,
  },
  -- {
  --   "SirZenith/oil-vcs-status",
  --   dependencies = {
  --     "stevearc/oil.nvim",
  --   },
  --   lazy = false,
  --   -- stylua: ignore
  --   -- keys = {
  --   --   { "<leader>e" },
  --   -- },
  --   opts = {
  --     -- win_opts = {
  --     --   signcolumn = "number"
  --     -- }
  --   },
  --   config = function(_, opts)
  --     require("oil-vcs-status").setup(opts)
  --   end,
  -- },
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
