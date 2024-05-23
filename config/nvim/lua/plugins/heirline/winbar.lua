local M = {}

function M.filename()
  return {

    -- icon
    -- {
    --   provider = function() end,
    -- },

    -- name
    {
      provider = function()
        return vim.fn.expand("%:t")
      end,
    },
  }
end

function M.setup()
  return {
    { provider = " " },
    -- filepath
    M.filename(),
    -- symbols
    { provider = "%=" },
  }
end

return M
