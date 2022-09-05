local status, context = pcall(require, 'treesitter-context')
if (not status) then
  return
end

context.setup({
  enable = true,
  throttle = true,
  max_lines = 0,
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

