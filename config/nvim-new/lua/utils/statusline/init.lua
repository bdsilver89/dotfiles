local M = {}

local modules = require("utils.statusline.modules")
local utils = require("utils.statusline.utils")

-- default = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
function M.render()
  return utils.generate(modules, {
    "mode",
    "file",
    "git",
    "%=",
    "lsp_msg",
    "%=",
    "diagnostics",
    -- "python_venv",
    -- "diagnostics",
    -- "command",
    -- "clients",
    "cwd",
    -- "total_lines",
  })
end

function M.setup()
  vim.o.statusline = "%!v:lua.require('utils.statusline').render()"
  utils.autocmds()
end

return M
