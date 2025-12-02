vim.api.nvim_create_user_command("PackUpdate", function(opts)
  if opts.args ~= "" then
    vim.pack.update({ opts.args })
  else
    vim.pack.update()
  end
end, {
  nargs = "?",
  desc = "Update packages (optionally specify a package name)",
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
})
