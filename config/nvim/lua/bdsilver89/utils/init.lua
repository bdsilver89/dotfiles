local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("bsilver89.utils." .. k)
    return t[k]
  end,
})

function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

return M
