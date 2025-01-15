return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      "mason.nvim",
    },
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format()
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      default_format_options = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters = {},
      formatters_by_ft = {},
      format_on_save = function(bufnr)
        if vim.g.autoformat == nil then
          vim.g.autoformat = true
        end
        local autoformat = vim.b[bufnr].autoformat
        if autoformat == nil then
          autoformat = vim.g.autoformat
        end
        if autoformat then
          return { timeout_ms = 500, lsp_fallback = true }
        end
      end,
    },
  },
}
