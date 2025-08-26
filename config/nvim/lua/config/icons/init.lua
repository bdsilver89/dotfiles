return setmetatable({}, {
  __index = function(t, k)
    local icon_pack = vim.g.has_nerd_font and "nerd" or "text"

    -- if not t[icon_pack] then
    --   if icon_pack == "nerd" then
    --     t.nerd = require("config.icons.nerd")
    --   elseif icon_pack == "text" then
    --     t.text = require("config.icons.text")
    --   end
    -- end

    t[k] = require("config.icons." .. icon_pack)[k]
    return t[k]
  end,
})
