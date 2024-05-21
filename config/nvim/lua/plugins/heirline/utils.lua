local Icons = require("config.icons")

local M = {}

local function escape(str)
  return str:gsub("%%", "%%%%")
end

---@param opts? table
---@param provider? function|string
---@return table|false
local function build_provider(opts, provider, _)
  return opts
      and {
        provider = provider,
        opts = opts,
        condition = opts.condition,
        on_click = opts.on_click,
        update = opts.update,
        hl = opts.hl,
      }
    or false
end

---@param opts table
---@param providers string[]
---@param setup? function
---@return table
function M.setup_providers(opts, providers, setup)
  setup = setup or build_provider
  for i, provider in ipairs(providers) do
    opts[i] = setup(opts[provider], provider, i)
  end
  return opts
end

---@param str string
---@param padding table
---@retrun string
function M.pad_string(str, padding)
  padding = padding or {}
  return str and str ~= "" and (" "):rep(padding.left or 0) .. str .. (" "):rep(padding.right or 0) or ""
end

function M.stylize(str, opts)
  opts = vim.tbl_deep_extend("force", {
    padding = { left = 0, right = 0 },
    separator = { left = "", right = "" },
    show_empty = false,
    escape = true,
    icon = { kind = "NONE", padding = { left = 0, right = 0 } },
  }, opts or {})
  local icon = M.pad_string(Icons.get_icon(opts.icon.group, opts.icon.kind), opts.icon.padding)
  return str
      and (str ~= "" or opts.show_empty)
      and opts.separator.left .. M.pad_string(icon .. (opts.escape and escape(str) or str), opts.padding) .. opts.separator.right
    or ""
end

return M
