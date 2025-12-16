local function get_package_names()
  local lock_path = vim.fn.stdpath("config") .. "/nvim-pack-lock.json"
  local content = vim.fn.readfile(lock_path)
  if #content == 0 then
    return {}
  end
  local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok or not data.plugins then
    return {}
  end
  return vim.tbl_keys(data.plugins)
end

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  if opts.args ~= "" then
    vim.pack.update({ opts.args })
  else
    vim.pack.update()
  end
end, {
  nargs = "?",
  desc = "Update packages (optionally specify a package name)",
  complete = function(arg_lead)
    local names = get_package_names()
    if arg_lead == "" then
      return names
    end
    return vim.tbl_filter(function(name)
      return name:find(arg_lead, 1, true) == 1
    end, names)
  end,
})

vim.api.nvim_create_user_command("PackDelete", function(opts)
  if opts.args == "" then
    vim.notify("PackDelete requires a package name", vim.log.levels.ERROR)
    return
  end
  vim.pack.rm(opts.args)
end, {
  nargs = 1,
  desc = "Delete a package by name",
  complete = function(arg_lead)
    local names = get_package_names()
    if arg_lead == "" then
      return names
    end
    return vim.tbl_filter(function(name)
      return name:find(arg_lead, 1, true) == 1
    end, names)
  end,
})

vim.api.nvim_create_user_command("PackStatus", function(opts)
  local names = opts.args ~= "" and { opts.args } or nil
  local plugins = vim.pack.get(names)
  if #plugins == 0 then
    vim.notify("No plugins found", vim.log.levels.INFO)
    return
  end
  local lines = {}
  for _, info in ipairs(plugins) do
    local name = info.spec.name
    local status = info.active and "active" or "inactive"
    local rev_short = info.rev:sub(1, 7)
    table.insert(lines, string.format("  %s (%s) [%s]", name, status, rev_short))
  end
  table.sort(lines)
  table.insert(lines, 1, "Installed plugins:")
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, {
  nargs = "?",
  desc = "Show status of installed packages",
  complete = function(arg_lead)
    local names = get_package_names()
    if arg_lead == "" then
      return names
    end
    return vim.tbl_filter(function(name)
      return name:find(arg_lead, 1, true) == 1
    end, names)
  end,
})
