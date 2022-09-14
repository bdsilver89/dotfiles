local status, ts = pcall(require, "nvim-treesitter.configs")
if (not status) then return end

ts.setup {
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  ensure_installed = 'all',
  -- ensure_installed = {
  --   "tsx",
  --   "toml",
  --   "php",
  --   "json",
  --   "yaml",
  --   "css",
  --   "html",
  --   "lua",
  --   "c",
  --   "cmake",
  --   "cpp",
  --   "dockerfile",
  --   "go",
  --   "bash",
  --   "python",
  --   "sql",
  --   "vim",
  -- },
  autotag = {
    enable = true,
  },
}

