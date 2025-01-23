return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      "mason.nvim",
    },
    event = "BufWritePre",
    lazy = true,
    cmd = "ConformInfo",
    opts = function()
      local opts = {
        default_format_options = {
          timeout_ms = 3000,
          async = false,
          quiet = false,
          lsp_format = "fallback",
        },
        formatters = {},
        formatters_by_ft = {},
        format_on_save = function(bufnr)
          if not require("config.util.format").enabled(bufnr) then
            return
          end
          return { timeout_ms = 5000, lsp_format = "fallback" }
        end,
      }
      return opts
    end,
  },
}
