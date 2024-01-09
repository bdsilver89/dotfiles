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
    { import = "plugins.base" },
    { import = "plugins.extras" },
  },
  defaults = {
    lazy = true,
    version = nil,
  },
  install = {
    missing = true,
  },
  checker = {
    enabled = true,
  },
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})