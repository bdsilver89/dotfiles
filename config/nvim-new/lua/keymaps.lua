local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit" })

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
