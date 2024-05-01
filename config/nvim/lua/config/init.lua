vim.uv = vim.uv or vim.loop

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.icons_enabled = false

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/folke/lazy.nvim.git",
    "--filter=blob:none",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  checker = { enabled = true },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    -- use some unicode icons if a nerd font is not available
    icons = vim.g.icons_enabled and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

require("config.options")
require("config.keymaps")
require("config.autocmds")


-- execute remaining user autocmds
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigOptions", modeline = false })
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigKeymaps", modeline = false })
vim.api.nvim_exec_autocmds("User", { pattern = "ConfigAutocmds", modeline = false })
