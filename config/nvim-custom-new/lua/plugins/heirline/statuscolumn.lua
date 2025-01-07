return {
  static = {
    get_signs = function()
      local buf = vim.fn.expand("%")
      return vim.tbl_map(function(sign)
        return vim.fn.sign_getdefined(sign.name)[1]
      end, vim.fn.sign_getplaced(buf, { group = "*", lnum = vim.v.lnum })[1].signs)
    end,
    resolve = function(self, name)
      for pat, cb in pairs(self.handlers) do
        if name:match(path) then
          return cb
        end
      end
    end,
    handlers = {
      ["GitSigns.*"] = function(_args)
        require("gitsigns").preview_hunk_inline()
      end,
      ["Dap.*"] = function(_args)
        require("dap").toggle_breakpoint()
      end,
      ["Diagnostic.*"] = function(_args)
        vim.diagnostic.open_float()
      end,
    },
  },
  init = function(self)
    local signs = {}
    for _, s in ipairs(self.get_signs()) do
      if s.name:find("GitSign") then
        self.git_sign = s
      else
        table.insert(signs, s)
      end
    end
    self.signs = signs
  end,
  {
    provider = "%s",
    on_click = {
      callback = function(self, ...)
        local mousepos = vim.fn.getmousepos()
        vim.api.nvim_win_set_cursor(0, { mousepos.line, mousepos.column })
        local sign_at_cursor = vim.fn.screenstring(mousepos.screenrow, mousepos.screencol)
        if sign_at_cursor ~= "" then
          local args = {
            mousepos = mousepos,
          }
          local signs = vim.fn.sign_getdefined()
          for _, sign in ipairs(signs) do
            local glyph = sign.text:gsub(" ", "")
            if sign_at_cursor == glyph then
              vim.defer_fn(function()
                self:resolve(sign.name)(args)
              end, 10)
              return
            end
          end
        end
      end,
      name = "heirline_signcol_callback",
      update = true,
    },
  },
  {
    provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}",
  },
  {
    provider = "%{% &fdc ? '%C ' : '' %}",
  },
  {
    provider = function(self)
      return self.git_sign and self.git_sign.text
    end,
    hl = function(self)
      return self.git_sign and self.git_sign.texthl
    end,
  },
}
