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

-- vim.api.nvim_create_user_command("PackDelete", function(opts)
--   if opts.fargs and #opts.fargs > 0 then
--     vim.pack.del(opts.fargs)
--     vim.notify("Removed plugin: " .. table.concat(opts.fargs, ", "))
--     return
--   end
--
--   local inactive_plugins = vim
--     .iter(vim.pack.get())
--     :filter(function(p)
--       return not p.active
--     end)
--     :map(function(p)
--       return p.spec.name
--     end)
--     :totable()
--
--   if #inactive_plugins == 0 then
--     vim.notify("No unused plugins found. Eveything is clean")
--     return
--   end
--
--   vim.pack.del(inactive_plugins)
--   vim.notify("Deleted unused plugins:\n- " .. table.concat(inactive_plugins, "\n- "))
-- end, {
--   nargs = "?",
--   complete = get_installed_plugins,
--   desc = "Delete specific plugin or all unused plugins",
-- })
