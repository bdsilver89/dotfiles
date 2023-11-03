local Conditions = require("heirline.conditions")
local Common = require("plugins.base.heirline.common")

local M = {}

function M.signs()
  return {
    init = function(self)
      local signs = vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), {
        group = "*",
        lnum = vim.v.lnum,
      })

      -- if #signs == 0 or signs[1] == nil or signs[1].signs == nil then
      if #signs == 0 or signs[1].signs == nil then
        self.sign = nil
        self.has_sign = false
        return
      end

      signs = vim.tbl_filter(function(sign)
        return not vim.startswith(sign.group, "gitsigns")
      end, signs[1].signs)

      if #signs == 0 then
        self.sign = nil
      else
        self.sign = signs[1]
      end

      self.has_sign = self.sign ~= nil
    end,
    provider = function(self)
      if self.has_sign then
        return vim.fn.sign_getdefined(self.sign.name)[1].text
      end
      return " "
    end,
    hl = function(self)
      if self.has_sign then
        if self.sign.group == "neotest-status" then
          if self.sign.name == "neotest_running" then
            return "NeotestRunning"
          end
          if self.sign.name == "neotest_failed" then
            return "NeotestFailed"
          end
          if self.sign.name == "neotest_passed" then
            return "NeotestPassed"
          end
          return "NeotestSkipped"
        elseif self.sign.group == "todo-signs" then
          if self.sign.name == "todo-sign-FIX" then
            return "TodoSignFIX"
          elseif self.sign.name == "todo-sign-HACK" then
            return "TodoSignHACK"
          elseif self.sign.name == "todo-sign-NOTE" then
            return "TodoSignNOTE"
          elseif self.sign.name == "todo-sign-PERF" then
            return "TodoSignPERF"
          elseif self.sign.name == "todo-sign-TEST" then
            return "TodoSignTEST"
          elseif self.sign.name == "todo-sign-TODO" then
            return "TodoSignTODO"
          elseif self.sign.name == "todo-sign-WARN" then
            return "TodoSignWARN"
          end
        end

        local hl = self.sign.name
        return (vim.fn.hlexists(hl) ~= 0 and hl)
      end
    end,
    on_click = {
      name = "sign_click",
      callback = function(self, ...)
        if self.handlers.sign then
          self.handlers.sign(self.click_args(self, ...))
        end
      end,
    },
  }
end

function M.line_numbers()
  return {
    provider = function()
      local lnum, rnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
      local num, relnum = vim.opt.number:get(), vim.opt.relativenumber:get()
      local signs = vim.opt.signcolumn:get():find("nu")
        and vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), { group = "*", lnum = lnum })[1].signs
      local str
      if virtnum ~= 0 then
        str = "%="
      elseif signs and #signs > 0 then
        local sign = vim.fn.sign_getdefined(signs[1].name)[1]
        str = "%=%#" .. sign.texthl .. "#" .. sign.text .. "%*"
      elseif not num and not relnum then
        str = "%="
      else
        local cur = relnum and (rnum > 0 and rnum or (num and lnum or 0)) or lnum
        str = (rnum == 0 and relnum) and cur .. "%=" or "%=" .. cur
      end
      return str
    end,
    on_click = {
      name = "line_number_click",
      callback = function(self, ...)
        if self.handlers.line_number then
          self.handlers.line_number(self.click_args(self, ...))
        end
      end,
    },
  }
end

function M.folds()
  return {
    condition = function()
      return vim.v.virtnum == 0
    end,
    init = function(self)
      self.lnum = vim.v.lnum
      self.folded = vim.fn.foldlevel(self.lnum) > vim.fn.foldlevel(self.lnum - 1)
    end,
    {
      condition = function(self)
        return self.folded
      end,
      {
        provider = function(self)
          if vim.fn.foldclosed(self.lnum) == -1 then
            return ""
          end
        end,
      },
      {
        provider = function(self)
          if vim.fn.foldclosed(self.lnum) ~= -1 then
            return ""
          end
        end,
      },
      hl = "Comment",
    },
    {
      condition = function(self)
        return not self.folded
      end,
      provider = " ",
    },
    on_click = {
      name = "fold_click",
      callback = function(self, ...)
        if self.handlers.fold then
          self.handlers.fold(self.click_args(self, ...))
        end
      end,
    },
  }
end

function M.gitsigns()
  return {
    {
      condition = function()
        return not Conditions.is_git_repo() or vim.v.virtnum ~= 0
      end,
      provider = "│ ",
      hl = "HeirlineStatusColumn",
    },
    {
      condition = function()
        return Conditions.is_git_repo() and vim.v.virtnum == 0
      end,
      init = function(self)
        self.bufnr = vim.api.nvim_get_current_buf()
        local signs = vim.tbl_map(function(sign)
          local ret = vim.fn.sign_getdefined(sign.name)[1]
          ret.priority = sign.priority
          return ret
        end, vim.fn.sign_getplaced(self.bufnr, { group = "*", lnum = vim.v.lnum })[1].signs)

        local extmarks = vim.api.nvim_buf_get_extmarks(
          self.bufnr,
          -1,
          { vim.v.lnum - 1, 0 },
          { vim.v.lnum - 1, -1 },
          { details = true, type = "sign" }
        )

        for _, extmark in ipairs(extmarks) do
          signs[#signs + 1] = {
            name = extmark[4].sign_hl_group or "",
            text = extmark[4].sign_text,
            texthl = extmark[4].sign_hl_group,
            priorityp = extmark[4].priority,
          }
        end

        table.sort(signs, function(a, b)
          return (a.priority or 0) < (b.priority or 0)
        end)

        self.sign = nil
        for _, s in ipairs(signs) do
          if s.name:find("GitSign") then
            self.sign = s
          end
        end

        self.has_sign = self.sign ~= nil
      end,
      provider = "│ ",
      hl = function(self)
        if self.has_sign then
          return self.sign.name
        end
        return "HeirlineStatusColumn"
      end,
      on_click = {
        name = "gitsigns_click",
        callback = function(self, ...)
          if self.handlers.git_signs then
            self.handlers.git_signs(self.click_args(self, ...))
          end
        end,
      },
    },
  }
end

function M.setup()
  return {
    condition = function()
      return not Conditions.buffer_matches({
        filetype = {
          "NvimTree",
          "^neo--tree$",
          "Trouble",
          "dashboard",
          "aerial",
          "aerial-nav",
          "lspinfo",
          "toggleterm",
          "harpoon",
        },
      })
    end,
    static = {
      handlers = {},
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
    },
    init = function(self)
      self.signs = {}

      self.handlers.signs = function(_)
        return vim.schedule(vim.diagnostic.open_float)
      end

      self.handlers.line_number = function(_)
        local dap_avail, dap = pcall(require, "dap")
        if dap_avail then
          vim.schedule(dap.toggle_breakpoint)
        end
      end

      self.handlers.gitsigns = function(_)
        local gitsigns_avail, gitsigns = pcall(require, "gitsigns")
        if gitsigns_avail then
          vim.schedule(gitsigns.preview_hunk)
        end
      end

      self.handlers.fold = function(args)
        local lnum = args.mousepos.line
        if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then
          return
        end
        vim.cmd.execute("'" .. lnum .. "fold" .. (vim.fn.foldclosed(lnum) == -1 and "close" or "open") .. "'")
      end
    end,
    M.signs(),
    Common.align(),
    M.line_numbers(),
    Common.space(),
    M.folds(),
    M.gitsigns(),
  }
end

return M
