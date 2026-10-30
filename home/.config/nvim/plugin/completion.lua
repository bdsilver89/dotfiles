vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("*") },
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/rafamadriz/friendly-snippets",
})

require("luasnip.loaders.from_vscode").lazy_load({
  paths = vim.fn.stdpath("config") .. "/snippets",
})

require("blink.cmp").setup({
  signature = {
    enabled = true,
  },
  keymap = {
    preset = "default",
    ["<cr>"] = { "accept", "fallback" },
    ["<tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<s-tab>"] = { "select_prev", "fallback" },
  },
  fuzzy = {
    implementation = "rust",
  },
  snippets = { preset = "luasnip" },
  completion = {
    ghost_text = {
      enabled = true,
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
    documentation = {
      auto_show = true,
    },
  },
})
