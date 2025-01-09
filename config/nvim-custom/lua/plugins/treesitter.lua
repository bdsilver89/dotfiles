return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", event = "VeryLazy" },
    },
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "diff",
        "dockerfile",
        "go",
        "http",
        "ini",
        "java",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "ninja",
        "printf",
        "python",
        "query",
        "regex",
        "rst",
        "ron",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "zig",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
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
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ak"] = { query = "@block.outer", desc = "around block" },
            ["ik"] = { query = "@block.inner", desc = "inside block" },
            ["ac"] = { query = "@class.outer", desc = "around class" },
            ["ic"] = { query = "@class.inner", desc = "inside class" },
            ["af"] = { query = "@function.outer", desc = "around function" },
            ["if"] = { query = "@function.inner", desc = "inside function" },
            ["ao"] = { query = "@loop.outer", desc = "around loop" },
            ["io"] = { query = "@loop.inner", desc = "inside loop" },
            ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
            ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
            ["aa"] = { query = "@parameter.outer", desc = "around parameter" },
            ["ia"] = { query = "@parameter.inner", desc = "inside parameter" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
