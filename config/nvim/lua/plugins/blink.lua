vim.pack.add({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/L3MON4D3/LuaSnip",
})

local cmp = require('blink.cmp')
cmp.build():wait(60000)
cmp.setup({
  keymap = {
    preset = "enter",
  },
  completion = {
    documentation = {
      auto_show = true,
    },
    menu = {
      scrollbar = false,
      draw = {
        gap = 2,
        columns = {
          { "kind_icon", "kind", gap = 1 },
          { "label", "label_description", gap = 1 },
        },
      },
    },
  },
  snippets = {
    preset = "luasnip",
  },
  cmdline = {
    enabled = false,
  },
  appearance = {
    kind_icons = require("icons").symbol_kinds,
  },
})
