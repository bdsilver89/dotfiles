-------------------------------------------------------------------------------
-- global setup
-------------------------------------------------------------------------------
pcall(function()
  vim.loader.enable()
end)

-------------------------------------------------------------------------------
-- global vim options
-------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- disable providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- enable glyph icons, if false fallsback to text icons
vim.g.enable_icons = true
vim.g.enable_mini_icons = false
vim.g.enable_nvim_devicons = true

-------------------------------------------------------------------------------
-- lazy.nvim bootstrap and setup
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "tutor",
        "rplugin",
        "synmenu",
        "optwin",
      },
    },
  },
})

-------------------------------------------------------------------------------
require("config.options")

local lazy_setup = vim.fn.argc(-1) == 0
if not lazy_setup then
  require("config.autocmds")
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    if lazy_setup then
      require("config.autocmds")
    end
    require("config.keymaps")

    -- ui setup
    require("config.ui.colorify").setup()
    require("config.ui.statusline").setup()

    vim.opt.statusline = "%{%v:lua.require'config.ui.statusline'.eval()%}"
    vim.opt.statuscolumn = "%!v:lua.require'config.ui.statuscolumn'.eval()"

    -- utils setup
    require("config.utils.term").setup()
  end,
})
