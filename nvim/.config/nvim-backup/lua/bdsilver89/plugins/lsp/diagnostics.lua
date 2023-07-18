local M = {}

local diagnostics_active = false

function M.toggle()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostics.show()
  else
    vim.diagnostics.hide()
  end
end

function M.setup(opts)
  opts = opts or {}
  opts.enabled = opts.enabled or true
  diagnostics_active = opts.enabled
end

return M
