local Conditions = require("heirline.conditions")
local Common = require("bdsilver89.plugins.heirline.common")

local M = {}

local git_ns = vim.api.nvim_create_namespace("gitsigns_extmark_signs_")

local function get_signs(bufnr, lnum)
  local signs = {}

  if vim.fn.has("nvim-0.10") == 0 then
    for _, sign in ipairs(vim.fn.sign_getplaced(bufnr, { group = "*", lnum = lnum })[1].signs) do
      local ret = vim.fn.sign_getdefined(sign.name)[1]
      if ret and not vim.startswith(sign.group, "gitsigns") then
        ret.priority = sign.priority
        signs[#signs + 1] = ret
      end
    end
  end

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
        texthl = extmark[4].sign_hl_group,
        priority = extmark[4].priority,
      }
    end
  end

  table.sort(signs, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)

  return signs
end

local function get_gitsigns(bufnr, lnum)
  local signs = {}

  if vim.fn.has("nvim-0.10") == 0 then
    for _, sign in ipairs(vim.fn.sign_getplaced(bufnr, { group = "*", lnum = lnum })[1].signs) do
      local ret = vim.fn.sign_getdefined(sign.name)[1]
      if ret and vim.startswith(sign.group, "gitsigns") then
        ret.priority = sign.priority
        signs[#signs + 1] = ret
      end
    end
  end

  local extmarks = vim.api.nvim_buf_get_extmarks(
    0,
    git_ns,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )

  for _, extmark in pairs(extmarks) do
    if extmark[4].ns_id == git_ns then
      signs[#signs + 1] = {
        name = extmark[4].sign_hl_group or "",
        text = extmark[4].sign_text,
        texthl = extmark[4].sign_hl_group,
        priority = extmark[4].priority,
      }
    end
  end

  table.sort(signs, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)

  return signs
end

function M.signs()
  return {
    init = function(self)
      self.sign = get_signs(self.bufnr, vim.v.lnum)[1]
    end,
    provider = function(self)
      return self.sign and self.sign.text or ""
    end,
    hl = function(self)
      return self.sign and self.sign.texthl
    end,
    on_click = {
      name = "sc_sign_click",
      update = true,
      callback = function(self, ...)
        local line = self.click_args(self, ...).mousepos.line
        local sign = get_signs(self.bufnr, line)[1]
        if sign then
          self:resolve(sign.name)
        end
      end,
    },
  }
end

function M.numbercolumn()
  return {
    provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}",
  }
end

function M.gitsign()
  return {
    {
      condition = function()
        return Conditions.is_git_repo()
      end,
      init = function(self)
        self.sign = get_gitsigns(self.bufnr, vim.v.lnum)[1]
      end,
      {
        provider = function(self)
          return self.sign and self.sign.text or "  "
          -- return "▎"
        end,
        hl = function(self)
          return self.sign and self.sign.texthl or { fg = "bg" }
        end,
        on_click = {
          name = "sc_gitsigns_click",
          callback = function(self, ...)
            self.handlers.GitSigns(self.click_args(self, ...))
          end,
        },
      },
    },
    {
      condition = function()
        return not Conditions.is_git_repo()
      end,
      Common.space(),
    },
  }
end

function M.setup()
  return {
    static = {
      bufnr = vim.api.nvim_win_get_buf(0),
    },
    condition = function()
      return not Conditions.buffer_matches({
        buftype = {
          "nofile",
          "prompt",
          "help",
          "quickfix",
          "terminal",
        },
        filetype = {
          "harpoon",
          "oil",
          "lspinfo",
          "toggleterm"
        },
      })
    end,
    M.signs(),
    Common.align(),
    M.numbercolumn(),
    -- M.fold(),
    M.gitsign(),
  }
end

return M
