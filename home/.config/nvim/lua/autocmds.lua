vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("config_textyank", { clear = true }),
  callback = function()
    vim.hl.hl_op()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("config_resized", { clear = true }),
  command = "tabdo wincmd =",
})
