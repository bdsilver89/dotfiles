local function load_module(name)
  pcall(require, "config." .. name)
end

-- load options first
load_module("options")

load_module("lazy")

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
  end,
})

local colorscheme = vim.o.background == "dark" and vim.g.colorscheme_dark or vim.g.colorscheme_light
local ok, _ = pcall(vim.cmd.colorscheme, colorscheme)
if not ok then
  vim.cmd.colorscheme("default")
end
