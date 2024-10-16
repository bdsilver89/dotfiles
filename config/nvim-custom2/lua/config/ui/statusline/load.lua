vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(args)
    if string.find(args.match, "end") then
      vim.cmd("redrawstatus")
    end
    vim.cmd("redrawstatus")
  end,
})
