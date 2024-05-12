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
    vim.g.enable_lang_ansible and { import = "plugins.lang.ansible" } or {},
    vim.g.enable_lang_bash and { import = "plugins.lang.bash" } or {},
    vim.g.enable_lang_c_cpp and { import = "plugins.lang.c_cpp" } or {},
    vim.g.enable_lang_cmake and { import = "plugins.lang.cmake" } or {},
    vim.g.enable_lang_docker and { import = "plugins.lang.docker" } or {},
    vim.g.enable_lang_go and { import = "plugins.lang.go" } or {},
    vim.g.enable_lang_java and { import = "plugins.lang.java" } or {},
    vim.g.enable_lang_json and { import = "plugins.lang.json" } or {},
    vim.g.enable_lang_lua and { import = "plugins.lang.lua" } or {},
    vim.g.enable_lang_markdown and { import = "plugins.lang.markdown" } or {},
    vim.g.enable_lang_python and { import = "plugins.lang.python" } or {},
    vim.g.enable_lang_rust and { import = "plugins.lang.rust" } or {},
    vim.g.enable_lang_tailwind and { import = "plugins.lang.tailwind" } or {},
    vim.g.enable_lang_terraform and { import = "plugins.lang.terraform" } or {},
    vim.g.enable_lang_typescript and { import = "plugins.lang.typescript" } or {},
    vim.g.enable_lang_yaml and { import = "plugins.lang.yaml" } or {},
    vim.g.enable_lang_zig and { import = "plugins.lang.zig" } or {},
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
