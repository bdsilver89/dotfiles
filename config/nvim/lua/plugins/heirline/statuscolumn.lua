local M = {}

-- local function get_signs(buf, lnum)
--   -- Get regular signs
--   ---@type Sign[]
--   local signs = {}
--
--   if vim.fn.has("nvim-0.10") == 0 then
--     -- Only needed for Neovim <0.10
--     -- Newer versions include legacy signs in nvim_buf_get_extmarks
--     for _, sign in ipairs(vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs) do
--       local ret = vim.fn.sign_getdefined(sign.name)[1] --[[@as Sign]]
--       if ret then
--         ret.priority = sign.priority
--         signs[#signs + 1] = ret
--       end
--     end
--   end
--
--   -- Get extmark signs
--   local extmarks = vim.api.nvim_buf_get_extmarks(
--     buf,
--     -1,
--     { lnum - 1, 0 },
--     { lnum - 1, -1 },
--     { details = true, type = "sign" }
--   )
--   for _, extmark in pairs(extmarks) do
--     signs[#signs + 1] = {
--       name = extmark[4].sign_hl_group or "",
--       text = extmark[4].sign_text,
--       texthl = extmark[4].sign_hl_group,
--       priority = extmark[4].priority,
--     }
--   end
--
--   -- Sort by priority
--   table.sort(signs, function(a, b)
--     return (a.priority or 0) < (b.priority or 0)
--   end)
--
--   return signs
-- end

function M.setup()
  return {
    -- {
    --   init = function(self)
    --     self.signs = get_signs()
    --   end,
    --   provider = function(self)
    --   end,
    -- },
    {
      provider = "%s",
    },
    {
      provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}",
    },
  }
end

return M
