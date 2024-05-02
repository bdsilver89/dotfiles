if not vim.g.vscode then
  return {}
end

-- Add some vscode specific settings
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimVSCode",
  callback = function()
    local vscode = require("vscode-neovim")

    -- change vim.notify to use vscode notification system
    vim.notify = vscode.notify
  end,
})

return {}
