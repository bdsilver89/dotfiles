if vim.loader and vim.loader.enable then
  vim.loader.enable()
end

require("options")

local lazy_autocmds = vim.fn.argc(-1) == 0
if not lazy_autocmds then
  require("autocmds")
end

local lazy_clipboard = vim.o.clipboard
vim.o.clipboard = ""

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    if lazy_autocmds then
      require("autocmds")
    end
    require("keymaps")

    if lazy_clipboard ~= nil then
      vim.o.clipboard = lazy_clipboard
    end
  end,
})

require("lazy_load")
require("lsp")
