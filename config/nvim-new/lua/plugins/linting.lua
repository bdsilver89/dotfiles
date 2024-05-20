return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        markdown = { "markdownlint" },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("config_lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
