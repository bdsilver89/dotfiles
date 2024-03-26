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
    "nvim-pack/nvim-spectre",
    keys = {
      {
        "<leader>sr",
        function()
          require("spectre").toggle()
        end,
        desc = "Replace in files (Spectre)",
      },
      {
        "<leader>sr",
        function()
          require("spectre").open_visual({ select_word = true })
        end,
        mode = "v",
        desc = "Replace in files (Spectre)",
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
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    -- stylua: ignore
    keys = {
      { "<leader>e", function() require("oil").toggle_float() end, desc = "Oil (float)" },
      { "<leader>E", function() require("oil").open() end, desc = "Oil (buffer)" },
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
