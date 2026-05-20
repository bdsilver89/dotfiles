vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
})

vim.api.nvim_create_user_command("FormatDisable", function(opts)
  if opts.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
  vim.notify("Autoformat disabled " .. (opts.bang and "(buffer)" or "(global)"), vim.log.levels.WARN)
end, { desc = "Disable autoformatting", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function(opts)
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
  vim.notify("Autoformat enabled", vim.log.levels.INFO)
end, { desc = "Enable autoformatting" })

local auto_format = true

vim.keymap.set("n", "<leader>uf", function()
  auto_format = not auto_format
  if auto_format then
    vim.cmd("FormatEnable")
  else
    vim.cmd("FormatDisable")
  end
end, { desc = "Toggle autoformat" })

vim.keymap.set({ "n", "v" }, "<leader>cn", "<cmd>ConformInfo<cr>", { desc = "Format info" })

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true }, function(err, did_edit)
    if not err and did_edit then
      vim.notify("Formatted", vim.log.levels.INFO)
    end
  end)
end, { desc = "Format" })
