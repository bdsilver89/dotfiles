return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufWritePost", "BufNewFile", "BufWritePre", "VeryLazy" },
    dependencies = {},
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = { },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "lua",
        "luadoc",
        "luap",
        "query",
        "regex",
        "vim",
        "vimdoc",
      },
      -- incremental_selection = {},
      -- textobjects = {},
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
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
