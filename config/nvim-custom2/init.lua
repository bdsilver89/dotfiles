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
vim.g.enable_mini_icons = true
vim.g.enable_nvim_devicons = false

-- which picker to use
vim.g.picker_fzf = true
vim.g.picker_telescope = false

-------------------------------------------------------------------------------
-- lazy.nvim bootstrap and setup
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  defaults = {
    lazy = true,
    version = false,
  },
  rocks = {
    enabled = false,
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
--- config setup
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

    -- utils setup
    require("config.utils.lazygit").setup()

    -- ui setup
    require("config.ui.colorify").setup()
    require("config.ui.statusline").setup()
    -- require("config.ui.winbar").setup()
  end,
})
