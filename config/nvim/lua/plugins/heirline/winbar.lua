local Conditions = require("heirline.conditions")
local Common = require("plugins.heirline.common")
local Utils = require("heirline.utils")

local M = {}

function M.setup()
  return {
    { provider = "%<" },
    Common.align(),
    Common.filenameblock(),
  }
end

return M
