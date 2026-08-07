vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

require("conform").setup({
  default_format_opts = {
    lsp_format = "fallback",
  },
  formatters_by_ft = require("lang").formatters_by_ft,
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer" })
