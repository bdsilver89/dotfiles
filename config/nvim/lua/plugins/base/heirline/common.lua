local M = {}

function M.align()
  return {
    provider = "%=",
  }
end

function M.space()
  return {
    provider = " ",
  }
end

function M.cut()
  return {
    provider = "%<",
  }
end

return M
