local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    { import = "bdsilver89.plugins" },
    { import = "bdsilver89.plugins.extras.db" },
    { import = "bdsilver89.plugins.extras.lang" },
  },
  defaults = {
    lazy = true,
    version = nil,
  },
  install = {
    missing = true,
    colorscheme = { "tokyonight" },
  },
  checker = {
    enabled = true,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netwrPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})
