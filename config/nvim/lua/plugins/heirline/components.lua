local Utils = require("plugins.heirline.utils")
local Providers = require("plugins.heirline.providers")

local M = {}

---@param opts? table
---@return table
local function builder(opts)
  opts = vim.tbl_deep_extend("force", { padding = { left = 0, right = 0 } }, opts or {})
  local children = {}
  local offset = 0

  if opts.padding.left > 0 then
    table.insert(children, { provider = Utils.pad_string(" ", { left = opts.padding.left - 1 }) })
    offset = offset + 1
  end

  for key, entry in pairs(opts) do
    if
      type(key) == "number"
      and type(entry) == "table"
      and Providers[entry.provider]
      and (entry.opts == nil or type(entry.opts) == "table")
    then
      entry.provider = Providers[entry.provider](entry.opts)
    end
    if type(key) == "number" then
      key = key + offset
    end
    children[key] = entry
  end

  if opts.padding.right > 0 then
    table.insert(children, { provider = Utils.pad_string(" ", { right = opts.padding.right - 1 }) })
  end

  -- TODO: surround
  return children
end

---@param opts? table
---@return table
function M.fill(opts)
  return vim.tbl_deep_extend("force", {
    provider = Providers.fill(),
    -- update = function()
    --   return false
    -- end,
  }, opts or {})
end

---@param opts? table
---@return table
function M.foldcolumn(opts)
  opts = vim.tbl_deep_extend("force", {
    foldcolumn = { padding = { right = 1 } },
    condition = function()
      return vim.opt.foldcolumn:get() ~= "0"
    end,
    on_click = {
      name = "fold_click",
      callback = function(...)
        local char = Utils.statuscolumn_clickargs(...).char
        local fillchars = vim.opt_local.fillchars:get()
        if char == fillchars.foldopen then
          vim.cmd("norm! zc")
        elseif char == fillchars.foldclose then
          vim.cmd("norm! zo")
        end
      end,
    },
  }, opts or {})
  return builder(Utils.setup_providers(opts, { "foldcolumn" }))
end

---@param opts? table
---@return table
function M.gitsigncolumn(opts)
  opts = vim.tbl_deep_extend("force", {
    gitsigncolumn = {},
    condition = function()
      return vim.opt.signcolumn:get() ~= "no"
    end,
    init = function(self)
      local git_ns = vim.api.nvim_create_namespace("gitsigns_extmark_signs_")
      local extmark = vim.api.nvim_buf_get_extmarks(
        0,
        git_ns,
        { vim.v.lnum - 1, 0 },
        { vim.v.lnum - 1, -1 },
        { limit = 1, details = true }
      )[1]

      self.sign = extmark and extmark[4]["sign_hl_group"]
      self.text = extmark and extmark[4]["sign_text"]
    end,
    hl = function(self)
      return self.sign or { fg = "bg" }
    end,
    on_click = {
      name = "sign_click",
      callback = function(...)
        local args = Utils.statuscolumn_clickargs(...)
        if args.sign then
          local handler = args.sign.name ~= "" and Utils.sign_handlers[args.sign.name]
          if not handler then
            handler = Utils.sign_handlers[args.sign.namespace]
          end
          if not handler then
            handler = Utils.sign_handlers[args.sign.texthl]
          end
          if handler then
            handler(args)
          end
        end
      end,
    },
  }, opts or {})
  return builder(Utils.setup_providers(opts, { "gitsigncolumn" }))
end

---@param opts? table
---@return table
function M.numbercolumn(opts)
  opts = vim.tbl_deep_extend("force", {
    numbercolumn = { padding = { right = 1 } },
    condition = function()
      return vim.opt.number:get() or vim.opt.relativenumber:get()
    end,
    on_click = {
      name = "number_click",
      callback = function(...)
        local args = Utils.statuscolumn_clickargs(...)
        if args.mods:find("c") then
          require("dap").toggle_breakpoint()
        end
      end,
    },
  }, opts or {})

  return builder(Utils.setup_providers(opts, { "numbercolumn" }))
end

---@param opts? table
---@return table
function M.signcolumn(opts)
  opts = vim.tbl_deep_extend("force", {
    signcolumn = {},
    condition = function()
      return vim.opt.signcolumn:get() ~= "no"
    end,
    init = function(self)
      local extmark = vim.api.nvim_buf_get_extmarks(
        0,
        -1,
        { vim.v.lnum - 1, 0 },
        { vim.v.lnum - 1, -1 },
        { limit = 1, details = true }
      )[1]

      if extmark then
        if not (extmark[4].sign_hl_group or ""):find("GitSign") then
          self.sign = extmark and extmark[4]["sign_hl_group"]
          self.text = extmark and extmark[4]["sign_text"]
        end
      end
    end,
    hl = function(self)
      return self.sign or { fg = "bg" }
    end,
    on_click = {
      name = "sign_click",
      callback = function(...)
        local args = Utils.statuscolumn_clickargs(...)
        if args.sign then
          local handler = args.sign.name ~= "" and Utils.sign_handlers[args.sign.name]
          if not handler then
            handler = Utils.sign_handlers[args.sign.namespace]
          end
          if not handler then
            handler = Utils.sign_handlers[args.sign.texthl]
          end
          if handler then
            handler(args)
          end
        end
      end,
    },
  }, opts or {})
  return builder(Utils.setup_providers(opts, { "signcolumn" }))
end

return M
