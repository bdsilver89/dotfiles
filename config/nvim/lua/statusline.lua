local icons = require("icons")

local M = {}

function M.branch()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return ""
  end
  return icons.git.branch .. head .. "  "
end

function M.diagnostics()
  local counts = vim.diagnostic.count(0)
  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warns = counts[vim.diagnostic.severity.WARN] or 0

  local parts = {}
  if errors > 0 then
    table.insert(parts, "%#DiagnosticError#" .. icons.diagnostics.ERROR .. errors)
  end
  if warns > 0 then
    table.insert(parts, "%#DiagnosticWarn#" .. icons.diagnostics.WARN .. warns)
  end
  if #parts == 0 then
    return ""
  end
  return table.concat(parts, "") .. "%#StatusLine# "
end

function M.lsp()
  local names = vim.iter(vim.lsp.get_clients({ bufnr = 0 }))
    :map(function(client)
      return client.name
    end)
    :totable()
  if #names == 0 then
    return ""
  end
  return table.concat(names, ",") .. "  "
end

vim.o.statusline = table.concat({
  ' %{%v:lua.require("statusline").branch()%}',
  '%f',
  ' %{&modified ? "' .. icons.misc.modified .. '" : ""}',
  '%{&readonly ? "' .. icons.misc.readonly .. '" : ""}',
  '%=',
  '%{%v:lua.require("statusline").diagnostics()%}',
  '%{%v:lua.require("statusline").lsp()%}',
  '%l:%c  %P ',
})

return M
