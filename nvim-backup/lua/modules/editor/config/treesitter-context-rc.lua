require("treesitter-context").setup({
  enable = true,
  throttle = true,
  max_lines = 0,
  trim_scope = 'outer',
  mode = 'cursor',
  separator = nil,
  zindex = 20,
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
})
