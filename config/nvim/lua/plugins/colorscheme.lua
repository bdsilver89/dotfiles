vim.g.default_colorscheme = "retrobox"

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
    enabled = false,
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = {
        overseer = true,
      },
    },
  },
}
