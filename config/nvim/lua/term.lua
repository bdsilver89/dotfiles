local M = {}

---@type LazyFloat?
local terminal = nil

--- Opens an interactive floating terminal.
---@param cmd? string|string[]
---@param opts? LazyCmdOptions
function M.float_term(cmd, opts)
  if vim.g.vscode then
    require("vscode").action("workbench.action.terminal.toggleTerminal")
    return
  end

  opts = vim.tbl_deep_extend("force", {
    ft = "lazyterm",
    size = { width = 0.7, height = 0.7 },
    persistent = true,
  }, opts or {})

  if terminal and terminal:buf_valid() and vim.b[terminal.buf].lazyterm_cmd == cmd then
    terminal:toggle()
  else
    terminal = require("lazy.util").float_term(cmd, opts)
    vim.b[terminal.buf].lazyterm_cmd = cmd
  end
end

---@param args? string|string[]
---@param opts? LazyCmdOptions
function M.lazygit(args, opts)
  local cmd = { "lazygit" } ---@type string[]

  args = type(args) == "string" and { args } or type(args) == "table" and args or {}
  vim.list_extend(cmd, args)

  opts = vim.tbl_deep_extend("force", {
    size = { width = 0.85, height = 0.8 },
    cwd = vim.b.gitsigns_status_dict.root,
  }, opts or {})

  M.float_term(cmd, opts)
end

return M
