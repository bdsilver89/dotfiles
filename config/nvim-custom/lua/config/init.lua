require("config.lazy")

local function load_module(name)
  require("config.util").try(function()
    require("config." .. name)
  end, { msg = "Failed loading `" .. name .. "`" })
end

-- load options first
load_module("options")

-- defer built-in clipboard loading since it can be slow
local lazy_clipboard = vim.opt.clipboard
vim.opt.clipboard = ""

local lazy_autocmds = vim.fn.argc(-1) == 0
if not lazy_autocmds then
  load_module("autocmds")
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    if lazy_autocmds then
      load_module("autocmds")
    end
    load_module("keymaps")
    if lazy_clipboard ~= nil then
      vim.opt.clipboard = lazy_clipboard
    end

    require("config.util.format").setup()
  end,
})

require("config.util").try(function()
  local colorscheme = vim.o.background == "dark" and vim.g.colorscheme_dark or vim.g.colorscheme_light
  vim.cmd.colorscheme(colorscheme)
end, { msg = "Could not load colorscheme" })
