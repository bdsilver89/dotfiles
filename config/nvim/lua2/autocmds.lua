vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("config_textyank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_user_command("PackClean", function()
  local inactive = vim.iter(vim.pack.get())
    :filter(function(p)
      return not p.active
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()

  if #inactive == 0 then
    vim.notify("No active plugins to remove")
    return
  end

  vim.pack.del(inactive)
  vim.notify("Removed: " .. table.concat(inactive, ", "))
end, { desc = "Remove plugins not in any vim.pack spec" })

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update all plugins" })

vim.api.nvim_create_user_command("StartupTime", function()
  local log = vim.fn.tempname()
  vim.system({ "nvim", "--startuptime", log, "-c", "q" }, { text = true }, function()
    vim.schedule(function()
      local lines = vim.fn.readfile(log)
      local last = lines[#lines - 1] or ""
      vim.notify('Startup: ' .. (last:match('^(%d+%.%d+)') or '?') .. ' ms')
    end)
  end)
end, { desc = "Measure startup time" })
