local M = {}

local align = { provider = "%=" }
local spacer = { provider = " ", hl = "HeirlineStatusColumn" }

local git_ns = vim.api.nvim_create_namespace("gitsigns_extmark_signs_")
local function get_signs(bufnr, lnum)
  local signs = {}

  local extmarks = vim.api.nvim_buf_get_extmarks(
    0,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )

  for _, extmark in pairs(extmarks) do
    -- Exclude gitsigns
    if extmark[4].ns_id ~= git_ns then
      signs[#signs + 1] = {
        name = extmark[4].sign_hl_group or "",
        text = extmark[4].sign_text,
        sign_hl_group = extmark[4].sign_hl_group,
        priority = extmark[4].priority,
      }
    end
  end

  table.sort(signs, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)

  return signs
end

function M.setup()
  return {
    condition = function()
      return not require("heirline.conditions").buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = { "alpha", "harpoon", "oil", "lspinfo", "toggleterm" },
      })
    end,
    static = {
      click_args = function(self, minwid, clicks, button, mods)
        local args = {
          minwid = minwid,
          clicks = clicks,
          button = button,
          mods = mods,
          mousepos = vim.fn.getmousepos(),
        }
        local sign = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
        if sign == " " then
          sign = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
        end
        args.sign = self.signs[sign]
        vim.api.nvim_set_current_win(args.mousepos.winid)
        vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })

        return args
      end,
      handlers = {
        Dap = function(_, _)
          require("dap").toggle_breakpoint()
        end,
        Fold = function(args)
          local line = args.mousepos.line
          if vim.fn.foldlevel(line) <= vim.fn.foldlevel(line - 1) then
            return
          end
          vim.cmd.execute("'" .. line .. "fold" .. (vim.fn.foldclosed(line) == -1 and "close" or "open") .. "'")
        end,
      },
    },
    -- init = function(self)
    --   self.signs = {}
    -- end,

    -- signs (excluding gitsigns)
    {
      init = function(self)
        local signs = get_signs(self.bufnr, vim.v.lnum)
        self.sign = signs[1]
      end,
      provider = function(self)
        return self.sign and self.sign.text or "  "
      end,
      hl = function(self)
        return self.sign and self.sign.sign_hl_group
      end,
      -- on_click = {
      --   name = "sign_click",
      --   update = true,
      --   callback = function(self, ...)
      --   end,
      -- },
    },

    align,

    -- line numbers
    {
      provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}",
      on_click = {
        name = "linenumber_click",
        callback = function(self, ...)
          self.handlers.Dap(self.click_args(self, ...))
        end,
      },
    },

    -- folds
    {
      init = function(self)
        self.can_fold = vim.fn.foldlevel(vim.v.lnum) > vim.fn.foldlevel(vim.v.lnum - 1)
      end,
      {
        condition = function(self)
          return vim.v.virtnum == 0 and self.can_fold
        end,
        provider = "%C",
      },
      {
        condition = function(self)
          return not self.can_fold
        end,
        spacer,
      },
      on_click = {
        name = "fold_click",
        callback = function(self, ...)
          self.handlers.Fold(self.click_args(self, ...))
        end,
      },
    },

    -- gitsign
    -- {
    --   conditon = function()
    --     return require("heirline.conditions").is_git_repo()
    --   end,
    --   init = function(self)
    --     local extmark = vim.api.nvim_buf_get_extmarks(
    --       0,
    --       git_ns,
    --       { vim.v.lnum - 1, 0 },
    --       { vim.v.lnum - 1, -1 },
    --       { limit = 1, details = true }
    --     )[1]
    --
    --     self.sign = extmark and extmark[4]["sign_hl_group"]
    --     self.text = extmark and extmark[4]["sign_text"]
    --   end,
    --   {
    --     provider = function(self)
    --       local text = vim.fn.strcharpart(self.text or "", 0, 1)
    --       text = text .. string.rep(" ", 1 - vim.fn.strchars(text))
    --       return text .. "%*"
    --     end,
    --     hl = function(self)
    --       return self.sign or { fg = "bg" }
    --     end,
    --     -- on_click = {
    --     --   name = "sc_gitsigns_click",
    --     --   callback = function(self, ...)
    --     --     self.handlers.GitSigns(self.click_args(self, ...))
    --     --   end,
    --     -- },
    --   },
    -- },
  }
end

return M
