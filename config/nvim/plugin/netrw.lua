-- Settings
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 30
vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 0

-- Mappings
vim.keymap.set("n", "<leader>e", function()
  vim.g.netrw_liststyle = 3
  vim.cmd("Lexplore")
end, { desc = "Explorer (tree)" })

vim.keymap.set("n", "-", function()
  vim.g.netrw_liststyle = 1
  vim.cmd("Ex %:p:h")
end, { desc = "Explorer (list)" })

-- Buffer-local mappings for netrw
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function(ev)
    local opts = { buffer = ev.buf, remap = true }
    vim.keymap.set("n", "h", "-^", opts)
    vim.keymap.set("n", "l", "<cr>", opts)
    vim.keymap.set("n", "H", "u", opts)
    vim.keymap.set("n", "<c-c>", "<cmd>bd<cr>", opts)
  end,
})
