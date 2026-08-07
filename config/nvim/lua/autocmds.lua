vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("config_hlyank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("config_resized", { clear = true }),
  callback = function()
    vim.cmd("wincmd =")
  end,
})

vim.api.nvim_create_user_command("PackClean", function()
  local inactive = vim
    .iter(vim.pack.get())
    :filter(function(x)
      return not x.active
    end)
    :map(function(x)
      return x.spec.name
    end)
    :totable()
  if #inactive == 0 then
    vim.notify("No inactive plugins to remove")
    return
  end
  vim.pack.del(inactive)
  vim.notify("Removed: " .. table.concat(inactive, ", "))
end, { desc = "Remove plugins not specified" })

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update plugins" })
