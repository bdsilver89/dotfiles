return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  dependencies = {
    "mason.nvim",
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    vim.g.autoformat = true
  end,
  opts = {
    formatters_by_ft = {
      c = { name = "clangd", lsp_format = "prefer" },
      cpp = { name = "clangd", lsp_format = "prefer" },
      lua = { "stylua" },
      rust = { name = "rust_analyzer", lsp_format = "prefer" },
      sh = { "shfmt" },
    },
    format_on_save = function()
      if not vim.g.autoformat then
        return nil
      end

      return {}
    end,
  },
}
