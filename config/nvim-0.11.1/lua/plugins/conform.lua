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
    formatters_by_ft = require("lang").formatter(),
    format_on_save = function()
      if not vim.g.autoformat then
        return nil
      end

      return {}
    end,
  },
}
