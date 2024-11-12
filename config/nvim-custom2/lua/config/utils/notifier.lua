local M = setmetatable({}, {
  __call = function(t, ...)
    return t.notify(...)
  end,
})

return M
