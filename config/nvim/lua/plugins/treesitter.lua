return {
  "nvim-treesitter/nvim-treesitter",
  event = "VeryLazy",
  lazy = vim.fn.argc(-1) == 0,
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
      "bash",
      "c",
      "cmake",
      "cpp",
      "diff",
      "html",
      "java",
      "javascript",
      "lua",
      "luadoc",
      "luap",
      "make",
      "markdown",
      "markdown_inline",
      "ninja",
      "python",
      "printf",
      "query",
      "regex",
      "rust",
      "sql",
      "toml",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
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
