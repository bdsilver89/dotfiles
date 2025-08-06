local add = MiniDeps.add

add("stevearc/conform.nvim")

vim.g.autoformat = true

local function toggle_autoformat()
  local state = vim.g.autoformat
  vim.g.autoformat = not state
  vim.notify(
    string.format("***%s autoformating***", vim.g.autoformat and "Enabled" or "Disabled"),
    vim.g.autoformat and vim.log.levels.INFO or vim.log.levels.WARN
  )
end

vim.keymap.set("n", "<leader>uf", toggle_autoformat, { desc = "Toggle autoformat" })
vim.api.nvim_create_user_command("ToggleFormat", toggle_autoformat, { nargs = 0, desc = "Toggle autoformat" })

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

require("conform").setup({
  format_on_save = function()
    if not vim.g.autoformat then
      return nil
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
  },
})
