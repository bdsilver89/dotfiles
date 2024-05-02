local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      opts = function(_, opts)
        if not vim.g.enable_icons then
          opts.icons = {
            diagnostics = {
              Error = "X",
            },
          }
        end
        return opts
      end,
      import = "lazyvim.plugins",
    },
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.editor.dial" },
    { import = "lazyvim.plugins.extras.editor.harpoon2" },
    { import = "lazyvim.plugins.extras.editor.trouble-v3" },
    vim.g.enable_lang_python and { import = "lazyvim.plugins.extras.formatting.black" } or {},
    vim.g.enable_lang_python and { import = "lazyvim.plugins.extras.formatting.prettier" } or {},
    vim.g.enable_lang_ansible and { import = "lazyvim.plugins.extras.lang.ansible" } or {},
    vim.g.enable_lang_c_cpp and { import = "lazyvim.plugins.extras.lang.clangd" } or {},
    vim.g.enable_lang_cmake and { import = "lazyvim.plugins.extras.lang.cmake" } or {},
    vim.g.enable_lang_docker and { import = "lazyvim.plugins.extras.lang.docker" } or {},
    vim.g.enable_lang_go and { import = "lazyvim.plugins.extras.lang.go" },
    vim.g.enable_lang_java and { import = "lazyvim.plugins.extras.lang.java" } or {},
    vim.g.enable_lang_json and { import = "lazyvim.plugins.extras.lang.json" } or {},
    vim.g.enable_lang_markdown and { import = "lazyvim.plugins.extras.lang.markdown" } or {},
    vim.g.enable_lang_python and { import = "lazyvim.plugins.extras.lang.python" } or {},
    vim.g.enable_lang_rust and { import = "lazyvim.plugins.extras.lang.rust" } or {},
    vim.g.enable_lang_tailwind and { import = "lazyvim.plugins.extras.lang.tailwind" } or {},
    vim.g.enable_lang_terraform and { import = "lazyvim.plugins.extras.lang.terraform" } or {},
    vim.g.enable_lang_typescript and { import = "lazyvim.plugins.extras.lang.typescript" } or {},
    vim.g.enable_lang_yaml and { import = "lazyvim.plugins.extras.lang.yaml" } or {},
    vim.g.enable_lang_typescript and { import = "lazyvim.plugins.extras.linting.eslint" } or {},
    { import = "lazyvim.plugins.extras.test" },
    { import = "lazyvim.plugins.extras.vscode" },
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
    -- { import = "lazyvim.plugins.extras.ui.edgy" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
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
