return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = false,
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    keys = {
      { '<c-space>', desc = 'Increment selection' },
      { '<bs>', desc = 'Shrink selection', mode = 'x'},
    },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      context_commentstring = { enable = true, enable_autocmd = false },
      ensure_installed = {
        'bash',
        'cmake',
        'c',
        'cpp',
        'help',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'regex',
        'tsx',
        'typescript',
        'vim',
        'yaml'
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<nop>',
          node_decremental = '<bs>',
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
