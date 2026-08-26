local function get_installed_plugins()
  return vim.tbl_keys(vim.pack.status() or {})
end

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  local targets = (opts.fargs and #opts.fargs > 0) and opts.fargs or nil
  local update_opts = { force = opts.bang }

  vim.pack.update(targets, update_opts)
end, {
  nargs = "?",
  bang = true,
  complete = get_installed_plugins,
  desc = "Update all or specified plugins",
})

-- p.active is unreliable for lazy plugins, scan declared src instead
local function get_declared_plugins()
  local declared = {}
  for _, file in ipairs(vim.api.nvim_get_runtime_file("plugin/*.lua", true)) do
    local content = io.open(file, "r")
    if content then
      local text = content:read("*a")
      content:close()
      for src in text:gmatch('src%s*=%s*"([^"]+)"') do
        local name = src:match(".+/(.+)$") or src
        declared[name] = true
      end
    end
  end
  return declared
end

vim.api.nvim_create_user_command("PackDelete", function(opts)
  if opts.fargs and #opts.fargs > 0 then
    vim.pack.del(opts.fargs)
    vim.notify("Removed plugin: " .. table.concat(opts.fargs, ", "))
    return
  end

  local declared = get_declared_plugins()
  local orphaned_plugins = vim
    .iter(vim.pack.get())
    :filter(function(p)
      return not declared[p.spec.name]
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()

  if #orphaned_plugins == 0 then
    vim.notify("No unused plugins found. Eveything is clean")
    return
  end

  vim.pack.del(orphaned_plugins)
  vim.notify("Deleted unused plugins:\n- " .. table.concat(orphaned_plugins, "\n- "))
end, {
  nargs = "?",
  complete = get_installed_plugins,
  desc = "Delete specific plugin or all unused plugins",
})
