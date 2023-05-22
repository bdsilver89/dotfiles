require("bdsilver89.config.options")
require("bdsilver89.config.lazy")

local function setup()
  require("bdsilver89.config.autocmds")
  require("bdsilver89.config.keymaps")
  vim.cmd.colorscheme("tokyonight")
end


if vim.fn.argc(-1) == 0 then
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("bsdilver89", { clear = true }),
    pattern = "VeryLazy",
    callback = function()
      setup()
    end,
  })
else
  setup()
end
