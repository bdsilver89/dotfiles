if vim.g.vscode then
  require("options")
  require("globals")
  require("vscode-config")
else
  require("options")
  require("globals")
  require("env")

  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath })
  end
  vim.opt.rtp:prepend(lazypath)

  require("lazy").setup({
    spec = {
      { import = "plugins" },
    },
    defaults = { lazy = true },
    install = { colorscheme = { vim.g.colorscheme } },
    performance = {
      rtp = {
        disabled_plugins = {
          "tohtml",
        },
      },
    },
  })

  require("autocmds")
  require("commands")
  require("keymaps")

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      require("utils.statuscolumn").setup()
      require("utils.statusline").setup()
      require("utils.colorify").setup()
    end,
  })

  vim.cmd.colorscheme(vim.g.colorscheme)
end
