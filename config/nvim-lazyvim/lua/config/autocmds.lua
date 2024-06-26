-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("filetype", {
  group = vim.api.nvim_create_augroup("expanded_close_with_q", { clear = true }),
  pattern = {
    "oil",
    "undotree",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
