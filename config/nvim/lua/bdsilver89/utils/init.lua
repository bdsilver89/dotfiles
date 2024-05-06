local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("bdsilver89.utils." .. k)
    return t[k]
  end,
})

return M
