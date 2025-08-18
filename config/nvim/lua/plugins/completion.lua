local add = MiniDeps.add

add("L3MON4D3/LuaSnip")
add("Saghen/blink.cmp")
-- add("giuxtaposition/blink-cmp-copilot")

require("blink.cmp").setup({
  snippets = { preset = "luasnip" },
  keymap = {
    preset = "default",
    ["<cr>"] = { "accept",  "fallback" },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  signature = { enabled = true },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
      },
    },
    ghost_text = { enabled = true },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    -- default = { "lsp", "path", "snippets", "buffer", "copilot" },
    per_filetype = {
      codecompanion = { "codecompanion", "buffer" },
    },
    -- providers = {
    --   copilot = {
    --     name = "copilot",
    --     module = "blink-cmp-copilot",
    --     score_offset = 100,
    --     async = true,
    --   },
    -- },
  },
  fuzzy = { implementation = "lua" },
})

