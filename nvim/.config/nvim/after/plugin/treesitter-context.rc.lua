local status, context = pcall(require, 'treesitter-context')
if (not status) then
  return
end

local nnoremap = require('bdsilver89.keymap').nnoremap

function ContextSetup(show_all_context)
  context.setup({
    enable = true,
    throttle = true,
    max_lines = 0,
    show_all_context = show_all_context,
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
end

nnoremap('<leader>cf', function() ContextSetup(true) end)
nnoremap('<leader>cp', function() ContextSetup(false) end)
ContextSetup(false)
