local pack = require("pack")

pack.add({
  {
    src = "saghen/blink.cmp",
    setup = false,
  },
  {
    src = "rafamadriz/friendly-snippets",
    setup = false,
  },
  {
    src = "L3MON4D3/LuaSnip",
    module_name = "luasnip",
    opts = { delete_check_events = "TextChanged" },
    on_setup = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    src = "saghen/blink.cmp",
    version = vim.version.range("1"),
    module_name = "blink.cmp",
    opts = {
      snippets = { preset = "luasnip" },
      keymap = { preset = "default" },
      completion = {
        documentation = { auto_show = true },
      },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = { lsp = { score_offset = 90 } },
      },
    },
  },
})
