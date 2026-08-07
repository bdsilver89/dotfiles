vim.pack.add({
  "https://github.com/mfussenegger/nvim-lint",
})

local lint = require("lint")
lint.linters_by_ft = require("lang").linters_by_ft

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("config_lint", { clear = true }),
  callback = function()
    if vim.bo.modifiable then
      lint.try_lint()
    end
  end,
})
