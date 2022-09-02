vim.api.nvim_command('set foldmethod=expr')
vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')

require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'c',
    'cmake',
    'cpp',
    'css',
    'dockerfile',
    'go',
    'gomod',
    'html',
    'http',
    'javascript',
    'json',
    'lua',
    'make',
    'markdown',
    'python',
    'rust',
    'scss',
    'sql',
    'toml',
    'typescript',
    'vim',
    'yaml',
  },
  ignore_install = { 'phpdoc', 'vala', 'tiger', 'slint', 'eex' },
  highlight = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
  },
})
