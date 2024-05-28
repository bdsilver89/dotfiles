local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- custom lazy events

-- LazyFile
local Event = require("lazy.core.handler.event")
Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

-- lazy setup
require("lazy").setup({
  spec = {
    { import = "plugins" },

    -- language packs
    { import = "plugins.extras.lang.ansible" },
    { import = "plugins.extras.lang.cmake" },
    { import = "plugins.extras.lang.cpp" },
    { import = "plugins.extras.lang.json" },
    { import = "plugins.extras.lang.lua" },
    { import = "plugins.extras.lang.markdown" },
    { import = "plugins.extras.lang.rust" },
    { import = "plugins.extras.lang.yaml" },

    { import = "plugins.extras.vscode" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = {},
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
    -- use unicode icons if no nerd icons are enabled
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
