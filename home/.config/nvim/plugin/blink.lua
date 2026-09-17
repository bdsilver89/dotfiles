vim.pack.add({
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
})

require("luasnip.loaders.from_vscode").lazy_load()

require("blink.cmp").build():pwait()
require("blink.cmp").setup({
  keymap = {
    preset = "enter",
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
  snippets = { preset = "luasnip" },
  cmdline = { enabled = false },
  fuzzy = { implementation = "prefer_rust" },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "buffer", "snippets", "path" },
  },
})
