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
    update = function()
      return false
    end,
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
  }, opts or {})
  return builder(Utils.setup_providers(opts, { "foldcolumn" }))
end

---@param opts? table
---@return table
function M.numbercolumn(opts)
  opts = vim.tbl_deep_extend("force", {
    numbercolumn = { padding = { right = 1 } },
    condition = function()
      return vim.opt.number:get() or vim.opt.relativenumber:get()
    end,
  }, opts or {})

  return builder(Utils.setup_providers(opts, { "numbercolumn" }))
end

return M
