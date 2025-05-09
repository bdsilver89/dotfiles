return {
  "nvim-treesitter/nvim-treesitter",
  event = "VeryLazy",
  version = false,
  build = ":TSUpdate",
  dependencies = {
    -- {
    --   "nvim-treesitter/nvim-treesitter-context",
    --   opts = {
    --     max_lines = 3,
    --     multiline_threshold = 1,
    --     min_window_height = 20,
    --   },
    -- },
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    ensure_installed = require("lang").treesitter(),
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<cr>",
        node_incremental = "<cr>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
    textobjects = {
      move = {
        enable = true,
        goto_next_start = {
          -- ["]k"] = { query = "@block.outer", desc = "Next block start" },
          ["]f"] = { query = "@function.outer", desc = "Next function start" },
          -- ["]a"] = { query = "@parameter.outer", desc = "Next parameter start" },
        },
        goto_next_end = {
          -- ["]K"] = { query = "@block.outer", desc = "Next block end" },
          ["]F"] = { query = "@function.outer", desc = "Next function end" },
          -- ["]A"] = { query = "@parameter.outer", desc = "Next parameter end" },
        },
        goto_previous_start = {
          -- ["[k"] = { query = "@block.outer", desc = "Previous block start" },
          ["[f"] = { query = "@function.outer", desc = "Previous function start" },
          -- ["[]a"] = { query = "@parameter.outer", desc = "Previous parameter start" },
        },
        goto_previous_end = {
          -- ["[K"] = { query = "@block.outer", desc = "Previous block end" },
          ["[F"] = { query = "@function.outer", desc = "Previous function end" },
          -- ["[A"] = { query = "@parameter.outer", desc = "Previous parameter end" },
        },
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
