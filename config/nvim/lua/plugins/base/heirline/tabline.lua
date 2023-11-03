local Common = require("plugins.base.heirline.common")
local Conditions = require("heirline.conditions")
local Utils = require("heirline.utils")
local Icons = require("utils.icons")

local M = {}

function M.side_padding()
  return {
    condition = function(self)
      self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
      return Conditions.buffer_matches({
        filetype = {
          "NvimTree",
          "OverseerList",
          "aerial",
          "dap-repl",
          "dapui_.",
          "edgy",
          "neo%-tree",
          "undotree",
        },
      }, vim.api.nvim_win_get_buf(self.winid))
    end,
    provider = function(self)
      return string.rep(" ", vim.api.nvim_win_get_width(self.winid) + 1)
    end,
    hl = "TabLine",
  }
end

function M.cwd()
  return {
    provider = function(self)
      local uis = vim.api.nvim_list_uis()
      local ui = uis[1] or { width = 80 }

      local extraparts = {
        --2 + 1, -- search symbol
        --2 + self.search_contents:len(), -- term padding
        2 + 5, -- counts
        8, -- icon and root text
        2 + 1, -- branch indicator
        self.branch:len(), -- branch
        2 + 7, -- clipboard indicator
        2 + 1, -- remote indicator
      }
      local extrachars = 0
      for _, len in pairs(extraparts) do
        extrachars = extrachars + len
      end

      local remaining = ui.width - extrachars
      local cwd = vim.fn.fnamemodify(self.cwd, ":~")
      local output = cwd:len() < remaining and cwd or vim.fn.pathshorten(cwd)
      return (" %s "):format(output)
    end,
    -- hl = "StatusLine",
  }
end
--
-- function M.buflist()
--   return {
--     condition = function()
--       return #vim.api.nvim_list_bufs() >= 2
--     end,
--     Utils.make_buflist({
--       {
--         provider = function(self)
--           local devicons_avail, devicons = pcall(require, "nvim-web_devicons")
--           if not devicons_avail then
--             return ""
--           end
--           local bufnr = self and self.bufnr or 0
--           local ft_icon = devicons.get_icon(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t"))
--           if not ft_icon then
--             ft_icon, _ = devicons.get_icon_by_filetype(vim.bo[bufnr].filetype, { default = true })
--           end
--           return ft_icon
--         end,
--       },
--       {
--         provider = function(self)
--           return self.bufnr or vim.api.nvim_get_current_buf()
--         end,
--       },
--       {
--         provider = function()
--           return " " .. Icons.misc.close .. " "
--         end,
--       },
--     }),
--     -- {
--     --   provider = function()
--     --     return " " .. Icons.misc.close .. " "
--     --   end,
--     --   -- on_click = {
--     --   --   name = "tabline_close_buffer",
--     --   --   callback = function()
--     --   --     -- vim.cmd.bufc
--     --   --   end,
--     --   -- },
--     --   hl = "Error",
--     -- },
--   }
-- end

function M.tablist()
  return {
    condition = function()
      return #vim.api.nvim_list_tabpages() >= 2
    end,
    Utils.make_tablist({
      provider = function(self)
        return (self and self.tabnr) and "%" .. self.tabnr .. "T " .. self.tabnr .. " %T" or ""
      end,
    }),
    {
      provider = function()
        return " " .. Icons.misc.close .. " "
      end,
      on_click = {
        name = "tabline_close_tab",
        callback = function()
          vim.cmd.tabclose()
        end,
      },
      hl = "Error",
    },
  }
end

function M.setup()
  return {
    init = function(self)
      self.branch = Conditions.is_git_repo() and vim.api.nvim_buf_get_var(0, "gitsigns_head") or ""
      self.cwd = vim.loop.cwd()
    end,
    hl = "Tabline",
    M.side_padding(),
    M.cwd(),
    -- M.buflist(),
    Common.align(),
    -- M.clipboard(),
    -- M.remote(),
    -- M.doctor(),
    M.tablist(),
    M.side_padding(),
  }
end

return M
