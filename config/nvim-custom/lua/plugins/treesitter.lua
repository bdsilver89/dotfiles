return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = true,
      },
    },
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    opts_extend = { "ensure_installed" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "diff",
        "dockerfile",
        -- "go",
        -- "gomod",
        -- "gowork",
        -- "gosum",
        -- "hcl",
        -- "java",
        -- "kotlin",
        -- "printf",
        "query",
        "regex",
        -- "rst",
        -- "sql",
        -- "terraform",
        "vim",
        "vimdoc",
        "xml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>ss",
          node_incremental = "<leader>si",
          scope_incremental = "<leader>sc",
          node_decremental = "<leader>sd",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ak"] = "@block.outer",
            ["ik"] = "@block.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ao"] = "@loop.outer",
            ["io"] = "@loop.inner",
            ["a?"] = "@conditional.outer",
            ["i?"] = "@conditional.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
        },
      },
    },
    config = function(_, opts)
      if vim.g.prefer_git then
        require("nvim-treesitter.install").prefer_git = true
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local tsc = require("treesitter-context")

      require("config.utils").toggle("<leader>ut", {
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      })

      return { mode = "cursor", max_lines = 3 }
    end,
  },
}
