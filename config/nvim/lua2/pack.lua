local M = {}

---@class PluginSpec
---@field src string
---@field name? string
---@field version? string|vim.VersionRange
---@field module_name? string
---@field opts? table|fun():table
---@field on_setup? fun():nil
---@field setup? false

--- param specs PluginSpec[]
local function configure(specs)
  local sources = vim.iter(specs)
    :map(function(spec)
      return { src = string.format("https://github.com/%s", spec.src), name = spec.name, version = spec.version }
    end)
    :totable()

  vim.pack.add(sources, { confirm = false })

  for _, spec in ipairs(specs) do
    if spec.setup ~= false then
      local module_name = spec.module_name or (spec.src:match(".+/(.+)"):gsub("%.nvim$", ""))
      local mod = require(module_name)
      if type(mod.setup) == "function" then
        local opts = spec.opts
        if type(opts) == "function" then
          opts = opts()
        end
        mod.setup(opts or {})
      end
    end
    if spec.on_setup then
      spec.on_setup()
    end
  end
end

---@param specs PluginSpec[]
function M.add(specs)
  configure(specs)
end

---@param events string|string[]
---@param specs PluginSpec[]
---@param opts? { pattern?: string|string[], replay?: boolean }
function M.add_on_event(events, specs, opts)
  opts = opts or {}
  local loaded = false
  local id
  id = vim.api.nvim_create_autocmd(events, {
    pattern = opts.pattern,
    callback = function(ev)
      if loaded then
        return true
      end
      loaded = true
      pcall(vim.api.nvim_del_autocmd, id)
      configure(specs)
      if opts.replay and ev.buf and vim.api.nvim_buf_is_valid(ev.buf) then
        vim.api.nvim_exec_autocmds(ev.event, { buffer = ev.buf, modeline = false })
      end
    end,
  })
end

---@param patterns string|string[]
---@param specs PluginSpec
function M.add_on_file_type(patterns, specs)
  M.add_on_event("FileType", specs, { pattern = patterns, replay = true })
end

---@param cmds string|string[]
---@param specs PluginSpec
function M.add_on_cmd(cmds, specs)
  cmds = type(cmds) == "string" and { cmds } or cmds ---@cast cmds string[]
  local loaded = false

  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(cmd, function(args)
      if not loaded then
        loaded = true
        for _, name in ipairs(cmds) do
          pcall(vim.api.nvim_del_user_command, name)
        end
        configure(specs)
      end
      vim.cmd({
        cmd = cmd,
        args = args.fargs,
        bang = args.bang,
        range = args.range > 0 and { args.line1, args.line2 } or nil,
        mods = args.smods,
      })
    end, {
      nargs = "*",
      bang = true,
      range = true,
      complete = "file",
      desc = "Load plugin, then run :" .. cmd,
    })
  end
end

---@param plugin_name string
---@param cmd string[]|fun():nil
function M.on_plugin_update(plugin_name, cmd)
  vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
      local data = ev.data
      if data.spec.name ~= plugin_name then
        return
      end
      if data.kind ~= "install" and data.kind ~= "update" then
        return
      end
      if type(cmd) == "function" then
        cmd()
      else
        vim.system(cmd, { cwd = data.path })
      end
    end,
  })
end

return M
