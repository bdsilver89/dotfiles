local function map(mode, lhs, cmd)
  vim.keymap.set(mode, lhs, function()
    vim.fn.VSCodeNotify(cmd)
  end, { noremap = true, silent = true })
end

map("n", "<leader>e", "workbench.action.toggleSidebarVisibility")

map("n", "<leader><space>", "workbench.action.quickOpen")
map("n", "<leader>/", "workbench.action.findInFiles")