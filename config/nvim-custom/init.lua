-- global vim options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- global PDE options
-- enable glyph icons, if false fallsback to text icons
vim.g.enable_icons = true

-- bootstrap lazy.nvim
local lazypath = vim.env.LAZY or vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or vim.uv.fs_stat(lazypath)) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "Press any key to exit...", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end
vim.opt.rtp:prepend(lazypath)

-- validate lazy.nvim
if not pcall(require, "lazy") then
  vim.api.nvim_echo({
    { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" },
    { "Press any key to exit...", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

-- lazy.nvim setup
require("lazy").setup({
  spec = {
    -- base plugin configuration
    { import = "plugins" },
    -- language-specific plugin configuration
    { import = "plugins.lang" },
  },
  checker = {
    enabled = true,
  },
  defaults = {
    lazy = true,
    version = false,
  },
  install = {
    missing = true,
    colorscheme = { "catppuccin" },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
  ui = {
    backdrop = 100,
    border = "rounded",
    icons = vim.g.enable_icons and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})

require("config.options")
require("config.autocmds")
require("config.keymaps")
