---Helps load config modules and stops on errors
---@param name string
local function load_module(name)
  local ok, err = pcall(require, "config." .. name)
  if not ok then
    vim.api.nvim_echo({
      { "Failed to load config module '" .. name .. "':\n", "ErrorMsg" },
      { err, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- load options
load_module("options")

-- load lsp configuration
load_module("lsp")

-- clipboard loading is very slow, defer the setting
local lazy_clipboard = vim.opt.clipboard
vim.opt.clipboard = ""

-- load lazy.nvim
load_module("lazy")

-- autocmds
local lazy_autocmds = vim.fn.argc(-1) == 0
if not lazy_autocmds then
  load_module("autocmds")
end

-- lazy init of everything else
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

vim.cmd.colorscheme("catppuccin")
