return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "LazyFile",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    opts_extend = { "ensure_installed" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "c",
        "diff",
        "http",
        "ini",
        "lua",
        "luadoc",
        "luap",
        "printf",
        "query",
        "regex",
        "vim",
        "vimdoc",
        "xml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      -- textobjects = {
      --   -- select = {
      --   --   enable = true,
      --   --   lookahead = true,
      --   --   keymaps = {
      --   --     ["ak"] = { query = "@block.outer", desc = "around block" },
      --   --     ["ik"] = { query = "@block.inner", desc = "inside block" },
      --   --     ["ac"] = { query = "@class.outer", desc = "around class" },
      --   --     ["ic"] = { query = "@class.inner", desc = "inside class" },
      --   --     ["af"] = { query = "@function.outer", desc = "around function" },
      --   --     ["if"] = { query = "@function.inner", desc = "inside function" },
      --   --     ["ao"] = { query = "@loop.outer", desc = "around loop" },
      --   --     ["io"] = { query = "@loop.inner", desc = "inside loop" },
      --   --     ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
      --   --     ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
      --   --     ["aa"] = { query = "@parameter.outer", desc = "around parameter" },
      --   --     ["ia"] = { query = "@parameter.inner", desc = "inside parameter" },
      --   --   },
      --   -- },
      --   move = {
      --     enable = true,
      --     -- set_jumps = true,
      --     goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
      --     goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
      --     goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
      --     goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
      --   },
      -- },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
