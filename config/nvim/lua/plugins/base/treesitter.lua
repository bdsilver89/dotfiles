return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    -- event = { "BufReadPost", "BufNewFile" },
    event = { "LazyFile", "VeryLazy" },
    dependencies = {
      -- "JoosephAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/nvim-treesitter-context",
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "windwp/nvim-ts-autotag",
        opts = {
          autotag = { enable_close_on_slash = false },
        },
      },
      {
        "windwp/nvim-autopairs",
        opts = {
          check_ts = true,
          enable_check_bracket_line = false,
          -- ts_config
          -- disable_filetype
          -- disable_in_macro
          -- ignored_next_char
          -- enable_moveright
          -- enable_afterquote
          map_c_w = false,
          map_bs = true,
          disable_in_visualblock = false,
          -- fast_wrap
        },
      },
    },
    opts = {
      autotag = { enable = true },
      -- TODO: context-commentstring
      -- highlight = {
      -- enable = true,
      --   disable = function(_, bufnr) return vim.b[bufnr].large_buf end,
      -- },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = "<m-space>",
        },
      },
      indent = { enable = true },
      auto_install = { enable = false },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ak"] = { query = "@block.outer", desc = "around block" },
            ["ik"] = { query = "@block.inner", desc = "inside block" },
            ["ac"] = { query = "@class.outer", desc = "around class" },
            ["ic"] = { query = "@class.inner", desc = "inside class" },
            ["ai"] = { query = "@conditional.outer", desc = "around conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "inside conditional" },
            ["af"] = { query = "@function.outer", desc = "around function " },
            ["if"] = { query = "@function.inner", desc = "inside function " },
            ["al"] = { query = "@loop.outer", desc = "around loop" },
            ["il"] = { query = "@loop.inner", desc = "inside loop" },
            ["aa"] = { query = "@parameter.outer", desc = "around argument" },
            ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
            ["a/"] = { query = "@comment.outer", desc = "around comment" },
            ["i/"] = { query = "@comment.inner", desc = "inside comment" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]k"] = { query = "@block.outer", desc = "Next block start" },
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
          },
          goto_next_end = {
            ["]K"] = { query = "@block.outer", desc = "Next block end" },
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
          },
          goto_previous_start = {
            ["[k"] = { query = "@block.outer", desc = "Previous block start" },
            ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
          },
          goto_previous_end = {
            ["[K"] = { query = "@block.outer", desc = "Previous block end" },
            ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            [">K"] = { query = "@block.outer", desc = "Swap next block" },
            [">F"] = { query = "@function.outer", desc = "Swap next function" },
            [">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
          },
          swap_previous = {
            ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
            ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
            ["<A"] = { query = "@parameter.inner", desc = "Swap previous argument" },
          },
        },
      },
      ensure_installed = {
        -- "bash",
        -- "c",
        -- "cmake",
        -- "cpp",
        -- "css",
        -- "dockerfile",
        "diff",
        -- "go",
        -- "gomod",
        -- "gowork",
        -- "gosum",
        "graphql",
        -- "hcl",
        -- "html",
        "ini",
        -- "java",
        -- "javascript",
        -- "json",
        -- "json5",
        -- "jsonc",
        -- "lua",
        -- "luadoc",
        -- "luap",
        -- "make",
        -- "markdown",
        -- "markdown_inline",
        -- "meson",
        -- "ninja",
        -- "norg",
        -- "proto",
        -- "python",
        "query",
        "regex",
        -- "ron",
        -- "rst",
        -- "rust",
        -- "scss",
        -- "sql",
        -- "terraform",
        -- "toml",
        -- "tsx",
        "vim",
        "vimdoc",
        -- "xml",
        -- "yaml",
        -- "zig",
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        local added = {} ---@type table<string, boolean>
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
