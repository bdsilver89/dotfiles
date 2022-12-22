local status, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

treesitter_configs.setup {
  ensure_installed = {
    "help",
    "javascript",
    "typescript",
    "c",
    "cpp",
    "lua",
    "rust",
    "go",
    "json",
    "yaml",
  },

  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>'
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        ['[M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  },
}

local status, treesitter_context = pcall(require, 'treesitter.context')
if (not status) then return end

treesitter_context.setup {
  enable = true,
  throttle = true,
  max_lines = 0,
  show_all_context = false,
  patterns = {
    default = {
      "function",
      "method",
      "for",
      "while",
      "if",
      "switch",
      "case",
    },
    rust = {
      "loop_expression",
      "impl_item",
    },
    typescript = {
      "class_declaration",
      "abstract_class_declaration",
      "else_clause",
    },
  },
}
