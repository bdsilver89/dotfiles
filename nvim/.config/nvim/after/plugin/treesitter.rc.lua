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
  autotag = {
    enable = true,
  },
}

