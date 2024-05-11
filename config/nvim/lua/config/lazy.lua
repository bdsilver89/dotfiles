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
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- base configuration
    { import = "plugins" },

    -- language modules
    -- vim.g.enable_lang_c_cpp and { import = "plugins.lang.c_cpp" } or {},
    -- vim.g.enable_lang_cmake and { import = "plugins.lang.cmake" } or {},
    -- vim.g.enable_lang_lua and { import = "plugins.lang.lua" } or {},
    -- vim.g.enable_lang_markdown and { import = "plugins.lang.markdown" } or {},
  },
  checker = {
    enabled = true,
  },
  defaults = {
    lazy = false,
    version = false,
  },
  change_detection = {
    enabled = true,
  },
  performance = {
    cache = {
      enabled = true,
    },
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
