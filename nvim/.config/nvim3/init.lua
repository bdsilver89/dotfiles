require("config.options")

local lazypath = vim.fn.stdpath("data") .. "lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  require("config.lazy").bootstrap(lazypath)
  require("config.lazy").setup()
  require("config.lazy").post_bootstrap()
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("config.lazy").setup()
require("config.keymaps")
require("config.autocmds")
