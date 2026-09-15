vim.pack.add({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
})

require("blink.cmp").setup({
  keymap = {
    preset = "super-tab",
  },
  completion = {
    documentation = { auto_show = true },
    menu = {
      draw = {
        gap = 2,
        columns = {
          { "kind_icon", "kind", gap = 1 },
          { "label", "label_description", gap = 1 },
        },
      },
    },
  },
  cmdline = { enabled = false },
  fuzzy = { implementation = "lua" },
  sources = {
    default = { "lsp", "buffer", "snippets", "path" },
  },
})
