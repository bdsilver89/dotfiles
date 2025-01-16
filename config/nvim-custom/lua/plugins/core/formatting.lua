return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      "mason.nvim",
    },
    lazy = true,
    cmd = "ConformInfo",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          require("config.util.format").register({
            name = "conform.nvim",
            priority = 100,
            primary = true,
            format = function(buf)
              require("conform").format({ bufnr = buf })
            end,
            sources = function(buf)
              local ret = require("conform").list_formatters(buf)
              return vim.tbl_map(function(v)
                return v.name
              end, ret)
            end,
          })
        end,
      })
    end,
    opts = {
      default_format_options = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters = {},
      formatters_by_ft = {},
    },
  },
}
