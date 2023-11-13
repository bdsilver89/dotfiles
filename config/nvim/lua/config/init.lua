require("config.options")
require("config.lazy")

local lazy_autocmds = vim.fn.argc(-1) == 0

if not lazy_autocmds then
  require("config.autocmds")
end

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("bdsilver89_config", { clear = true }),
  pattern = "VeryLazy",
  callback = function()
    if lazy_autocmds then
      require("config.autocmds")
    end

    require("config.keymaps")
  end,
})

vim.cmd.colorscheme("catppuccin")
