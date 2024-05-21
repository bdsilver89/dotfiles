local Icons = require("config.icons")

local M = {}

M.sign_handlers = {}

local function gitsigns_handler(_)
  local gitsigns_avail, gitsigns = pcall(require, "gitsigns")
  if gitsigns_avail then
    vim.schedule(gitsigns.preview_hunk)
  end
end
for _, sign in ipairs({ "Topdelete", "Untracked", "Add", "Change", "Changedelete", "Delete" }) do
  local name = "GitSigns" .. sign
  if not M.sign_handlers[name] then
    M.sign_handlers[name] = gitsigns_handler
  end
end
M.sign_handlers["gitsigns_extmark_signs_"] = gitsigns_handler

local diagnostics_handler = function(args)
  if args.mods:find("c") then
    vim.schedule(vim.lsp.buf.code_action)
  else
    vim.schedule(vim.diagnostic.open_float)
  end
end
for _, sign in ipairs({ "Error", "Hint", "Info", "Warn" }) do
  local name = "DiagnosticSign" .. sign
  if not M.sign_handlers[name] then
    M.sign_handlers[name] = diagnostics_handler
  end
end

local dap_breakpoint_handler = function(_)
  local dap_avail, dap = pcall(require, "dap")
  if dap_avail then
    vim.schedule(dap.toggle_breakpoint)
  end
end
for _, sign in ipairs({ "", "Rejected", "Condition" }) do
  local name = "DapBreakpoint" .. sign
  if not M.sign_handlers[name] then
    M.sign_handlers[name] = dap_breakpoint_handler
  end
end

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
        init = opts.init,
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

---@param self any
---@param minwid any
---@param clicks any
---@param button any
---@param mods any
---@return table
function M.statuscolumn_clickargs(self, minwid, clicks, button, mods)
  local args = {
    minwid = minwid,
    clicks = clicks,
    button = button,
    mods = mods,
    mousepos = vim.fn.getmousepos(),
  }
  args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
  if args.char == " " then
    args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
  end

  if not self.signs then
    self.signs = {}
  end

  if not args.signs then
    if not self.bufnr then
      self.bufnr = vim.api.nvim_get_current_buf()
    end
    local row = args.mousepos.line - 1
    for _, extmark in
      ipairs(vim.api.nvim_buf_get_extmarks(self.bufnr, -1, { row, 0 }, { row, -1 }, { details = true, type = "sign" }))
    do
      local sign = extmark[4]
      if not (self.namespaces and self.namespaces[sign.ns_id]) then
        self.namespaces = {}
        for ns, ns_id in pairs(vim.api.nvim_get_namespaces()) do
          self.namespaces[ns_id] = ns
        end
      end
      if sign.sign_text then
        self.signs[sign.sign_text:gsub("%s", "")] = {
          name = sign.sign_name,
          text = sign.sign_text,
          texthl = sign.sign_hl_group or "NoTexthl",
          namespace = sign.ns_id and self.namespaces[sign.ns_id],
        }
      end
    end
    args.sign = self.signs[args.char]
  end

  vim.api.nvim_set_current_win(args.mousepos.winid)
  vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })
  return args
end

return M
