-- Format and lint only. Test/debug/task running lives in the terminal.
--
-- Formatters resolve the project's binary before any global one, so the editor
-- and CI agree on version. A missing tool just means no formatting, not the
-- wrong formatting.

local util = require("conform.util")

require("conform").setup({
  formatters = {
    prettier = { command = util.from_node_modules("prettier") },
    prettierd = { command = util.from_node_modules("prettierd") },
    ruff_format = { command = util.find_executable({ ".venv/bin/ruff", "venv/bin/ruff" }, "ruff") },
    ruff_organize_imports = { command = util.find_executable({ ".venv/bin/ruff", "venv/bin/ruff" }, "ruff") },
  },
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
    rust = { "rustfmt" },
    python = { "ruff_format", "ruff_organize_imports" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    sh = { "shfmt" },
    bash = { "shfmt" },
    toml = { "taplo" },
    lua = { "stylua" },
  },
  format_on_save = function(buf)
    if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then
      return
    end
    return { timeout_ms = 750, lsp_format = "fallback" }
  end,
})

vim.api.nvim_create_user_command("FormatToggle", function(a)
  local scope = a.bang and "b" or "g"
  vim[scope].disable_autoformat = not vim[scope].disable_autoformat
  vim.notify(
    ("Autoformat %s (%s)"):format(vim[scope].disable_autoformat and "off" or "on", a.bang and "buffer" or "global")
  )
end, { bang = true, desc = "Toggle format-on-save (! = buffer only)" })

-- Only for what no language server already covers.
local lint = require("lint")
lint.linters_by_ft = {
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  dockerfile = { "hadolint" },
  yaml = { "yamllint" },
}

-- On write only: InsertLeave spawns a subprocess every time you leave insert.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("config_lint", { clear = true }),
  callback = function()
    lint.try_lint()
  end,
})
