local M = {}

---@class LazySpec
---@field [1] string
---@field name? string
---@field version? string|vim.VersionRange
---@field deps? (string|LazySpec)[]
---@field opts? table|fun(): table
---@field main? string
---@field config? fun(opts:table)
---@field event? string|string[]
---@field ft? string|string[]
---@field cmd? string|string[]
---@field keys? table[]
---@field lazy? boolean

local by_name = {} ---@type table<string, table>
local order = {}

local function list(v)
  return v == nil and {} or type(v) == "table" and v or { v }
end

local function url(src)
  return src:match("^%a[%w+.-]*://") and src or ("https://github.com/" .. src)
end

local function register(s, is_dep)
  if type(s) == "string" then
    s = { s }
  end
  s.name = s.name or s[1]:match("([^/]+)$"):gsub("%.git$", "")
  local prev = by_name[s.name]
  if prev then
    if not (prev.is_dep and is_dep) then
      return prev
    end
    for k in pairs(prev) do
      prev[k] = nil
    end
    for k, v in pairs(s) do
      prev[k] = v
    end
  else
    by_name[s.name] = s
    table.insert(order, s)
  end
  s.main = s.main or s.name:gsub("%.nvim$", ""):gsub("^nvim%-", "")
  s.is_dep = is_dep
  for i, d in ipairs(s.deps or {}) do
    s.deps[i] = register(d, true).name
  end
  return s
end

local function source_after(s)
  if vim.v.vim_did_enter == 1 then
    for _, f in ipairs(vim.fn.glob(s.path .. "/after/plugin/**/*.{vim,lua}", false, true)) do
      vim.cmd.source({ f, magic = { file = false } })
    end
  end
end

---@param name string
function M.load(name)
  local s = by_name[name]
  if not s then
    return vim.notify("Unknown plugin " .. name, vim.log.levels.ERROR)
  end
  if s.loaded then
    return
  end
  s.loaded = true
  for _, d in ipairs(s.deps or {}) do
    M.load(d)
  end
  local ok, err = pcall(vim.cmd.packadd, { vim.fn.escape(name, " "), magic = { file = false } })
  if not ok then
    return vim.notify(("packadd %s: %s"):format(name, err), vim.log.levels.ERROR)
  end
  source_after(s)
  local opts = type(s.opts) == "function" and s.opts() or s.opts or {}
  local ok2, err2 = pcall(function()
    if s.config then
      s.config(opts)
    elseif s.opts ~= nil then
      require(s.main).setup(opts)
    end
  end)
  if not ok2 then
    vim.notify(("config %s: %s"):format(name, err2), vim.log.levels.ERROR)
  end
end

local function on_event(s)
  local group = vim.api.nvim_create_augroup("config_lazy_" .. s.name, { clear = true })
  local function trigger(events, pattern)
    vim.api.nvim_create_autocmd(events, {
      group = group,
      pattern = pattern,
      once = true,
      callback = function(ev)
        if s.loaded then
          return
        end
        M.load(s.name)
        vim.api.nvim_exec_autocmds(ev.event, { buffer = ev.buf, data = ev.data, modeline = false })
      end,
    })
  end
  for _, e in ipairs(list(s.event)) do
    local ev, pat = e:match("^(%S+)%s(.+)$")
    if ev == "User" then
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = pat,
        once = true,
        callback = function()
          M.load(s.name)
        end,
      })
    else
      trigger(ev or e, pat)
    end
  end
  if s.ft then
    trigger("FileType", list(s.ft))
  end
end

local function on_cmd(s)
  for _, c in ipairs(list(s.cmd)) do
    vim.api.nvim_create_user_command(c, function(o)
      pcall(vim.api.nvim_del_user_command, c)
      M.load(s.name)
      vim.cmd({
        cmd = c,
        args = o.fargs,
        bang = o.bang,
        mods = o.smods,
        range = o.range == 2 and { o.line1, o.line2 } or o.range == 1 and { o.line1 } or nil,
      })
    end, {
      nargs = "*",
      bang = true,
      range = true,
      complete = function(load, line)
        M.load(s.name)
        return vim.fn.getcompletion(line, "cmdline")
      end,
    })
  end
end

local function on_keys(s)
  for _, k in ipairs(s.keys or {}) do
    local lhs, rhs = k[1], k[2]
    vim.keymap.set(k.mode or "n", lhs, function()
      M.load(s.name)
      if type(rhs) == "function" then
        return rhs()
      end
      vim.api.nvim_feedkeys(vim.keycode(rhs or lhs), "m", false)
    end, { desc = k.desc, silent = k.silent ~= false })
  end
end

local function run_build(s)
  local b = s.build
  if not b then
    return
  end
  M.load(s.name)
  if type(b) == "function" then
    return b()
  end
  if b:sub(1, 1) == ":" then
    return vim.cmd(b:sub(2))
  end
  vim.system({ vim.o.shell, "-c", b }, { cwd = s.path }):wait()
end

local build_hook_set = false

---@param specs (string|LazySpec)[]
function M.add(specs)
  if not build_hook_set then
    build_hook_set = true
    vim.api.nvim_create_autocmd("PackChanged", {
      group = vim.api.nvim_create_augroup("config_lazy_build", { clear = true }),
      callback = function(ev)
        local s = by_name[ev.data.spec.name]
        if s and (ev.data.kind == "install" or ev.data.kind == "update") then
          s.path = ev.data.path
          vim.schedule(function()
            run_build(s)
          end)
        end
      end,
    })
  end

  local batch = {}
  for _, s in ipairs(specs) do
    local before = #order
    register(s)
    for i = before + 1, #order do
      table.insert(batch, order[i])
    end
  end
  batch = vim.tbl_filter(function(s)
    return not s.path
  end, batch)

  vim.pack.add(
    vim.tbl_map(function(s)
      return { src = url(s[1]), name = s.name, version = s.version }
    end, batch),
    {
      load = function(p)
        by_name[p.spec.name].path = p.path
      end,
    }
  )

  for _, s in ipairs(batch) do
    if s.init then
      s.init()
    end
  end

  for _, s in ipairs(batch) do
    local triggered = s.event or s.ft or s.cmd or s.keys
    if s.event or s.ft then
      on_event(s)
    end
    if s.cmd then
      on_cmd(s)
    end
    if s.keys then
      on_keys(s)
    end
    if not triggered and not s.lazy and not s.is_dep then
      M.load(s.name)
    end
  end
end

vim.api.nvim_create_user_command("LazyStatus", function()
  local out = {}
  for _, s in ipairs(order) do
    table.insert(out, ("%s %s"):format(s.loaded and "●" or "○", s.name))
  end
  vim.notify(table.concat(out, "\n"))
end, {})

return M
