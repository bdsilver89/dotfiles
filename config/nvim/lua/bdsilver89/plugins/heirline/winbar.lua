local Conditions = require("heirline.conditions")
local Common = require("bdsilver89.plugins.heirline.common")
local HUtils = require("heirline.utils")

local M = {}

function M.terminal_winbar()
  return {
    condition = function()
      return Conditions.buffer_matches({
        buftype = { "terminal" },
      })
    end,
    -- HUtils.surround({ "", "" }, HUtils.get_highlight("Tabline").fg, {
    Common.terminal_name(),
    -- }),
  }
end

function M.inactive_winbar()
  return {
    condition = function()
      return not Conditions.is_active()
    end,
    -- HUtils.surround({ "", "" }, HUtils.get_highlight("Tabline").fg, {
    Common.filenameblock(),
    -- }),
    hl = { fg = "gray", force = true },
  }
end

function M.default_winbar()
  return {
    Common.filenameblock(),
  }
end

function M.setup()
  return {
    fallthrough = false,
    M.terminal_winbar(),
    M.inactive_winbar(),
    M.default_winbar(),
  }
end

return M
