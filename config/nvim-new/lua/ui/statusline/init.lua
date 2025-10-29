local M = {}

local modules = require("ui.statusline.modules")
local utils = require("ui.statusline.utils")

function M.render()
  local order = {
    "mode",
    "file",
    "git",
    "%=",
    "lsp_msg",
    "%=",
    -- "python_venv",
    "diagnostics",
    -- "command",
    "clients",
    "cwd",
    "cursor",
    -- "total_lines",
  }

  local result = {}

  for _, v in ipairs(order) do
    local module = modules[v]
    module = type(module) == "string" and module or module()
    table.insert(result, module)
  end

  return table.concat(result)
end

function M.setup()
  vim.o.statusline = "%!v:lua.require('ui.statusline').render()"
  utils.autocmds()
end

return M
