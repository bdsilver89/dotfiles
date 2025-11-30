local map = function(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader><space>", "<cmd>Find<cr>")
map("n", "<leader>/", function()
  vscode.call("workbench.action.findInFiles")
end)
