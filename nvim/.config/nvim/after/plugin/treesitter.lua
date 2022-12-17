require('nvim-treesitter.configs').setup {
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
  }
}

require('treesitter-context').setup {
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
