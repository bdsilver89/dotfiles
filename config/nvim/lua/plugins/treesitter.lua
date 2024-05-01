return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    cmd = {
      "TSBufDisable",
      "TSBufEnable",
      "TSBufToggle",
      "TSDisable",
      "TSEnable",
      "TSToggle",
      "TSInstall",
      "TSInstallInfo",
      "TSInstallSync",
      "TSModuleInfo",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
    },
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
    opts = {
      ensure_installed = {
        "c",
        "lua",
      },
      highlight = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ak"] = { query = "@block.outer", desc = "around block" },
            ["ik"] = { query = "@block.innter", desc = "inside block" },
            ["ac"] = { query = "@class.outer", desc = "around class" },
            ["ic"] = { query = "@class.innter", desc = "inside class" },
            ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
            ["i?"] = { query = "@conditional.innter", desc = "inside conditional" },
            ["af"] = { query = "@function.outer", desc = "around function" },
            ["if"] = { query = "@function.innter", desc = "inside function" },
            ["ao"] = { query = "@loop.outer", desc = "around loop" },
            ["io"] = { query = "@loop.innter", desc = "inside loop" },
            ["aa"] = { query = "@parameter.outer", desc = "around parameter" },
            ["ia"] = { query = "@parameter.innter", desc = "inside parameter" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]k"] = { query = "@block.outer", desc = "Next block start" },
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]a"] = { query = "@parameter.outer", desc = "Next argument start" },
          },
          goto_next_end = {
            ["]K"] = { query = "@block.outer", desc = "Next block end" },
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]A"] = { query = "@parameter.outer", desc = "Next argument end" },
          },
          goto_prev_start = {
            ["[k"] = { query = "@block.outer", desc = "Prev block start" },
            ["[f"] = { query = "@function.outer", desc = "Prev function start" },
            ["[a"] = { query = "@parameter.outer", desc = "Prev argument start" },
          },
          goto_prev_end = {
            ["[K"] = { query = "@block.outer", desc = "Prev block end" },
            ["[F"] = { query = "@function.outer", desc = "Prev function end" },
            ["[A"] = { query = "@parameter.outer", desc = "Prev argument end" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            [">K"] = { query = "@block.outer", desc = "Swap next block" },
            [">F"] = { query = "@function.outer", desc = "Swap next function" },
            [">A"] = { query = "@parameter.outer", desc = "Swap next argument" },
          },
          swap_prev = {
            ["<K"] = { query = "@block.outer", desc = "Swap prev block" },
            ["<F"] = { query = "@function.outer", desc = "Swap prev function" },
            ["<A"] = { query = "@parameter.outer", desc = "Swap prev argument" },
          },
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end

      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>ut", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
    },
    opts = { mode = "cursor", max_lines = 3 },
  },
}
