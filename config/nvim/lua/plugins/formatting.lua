vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

vim.g.autoformat = true
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

require("conform").setup({
  formatters_by_ft = {
    c = { name = "clangd", timeout_ms = 500, lsp_format = "prefer" },
    cpp = { name = "clangd", timeout_ms = 500, lsp_format = "prefer" },
    lua = { "stylua" },
    rust = { name = "rust_analyzer", timeout_ms = 500, lsp_format = "prefer" },
    sh = { "shfmt" },
    ["_"] = { "trim_whitespace", "trim_newlines" },
  },
  format_on_save = function()
    if not vim.g.autoformat then
      return nil
    end
    return { timeout_ms = 5000, lsp_format = "fallback" }
  end,
})

vim.keymap.set("n", "<leader>uf", function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify(string.format("%s formatting", vim.g.autoformat and "Enabling" or "Disabling"))
end, { desc = "Toggle autoformat" })
