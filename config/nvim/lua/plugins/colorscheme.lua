vim.g.default_colorscheme = "catppuccin"

if not vim.g.vscode then
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      vim.cmd.colorscheme(vim.g.default_colorscheme)
    end,
  })
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {},
  },
}
