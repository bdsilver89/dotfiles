return {
  "Saghen/blink.cmp",
  event = "InsertEnter",
  version = "1.*",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      build = vim.fn.executable("make") == 1 and "make install_jsregexp" or nil,
      dependencies = {
        {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
    },
  },
  opts = {
    keymap = {
      preset = "enter",
    },
    signature = { enabled = true },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
      },
      menu = {
        auto_show = true,
        draw = {
          treesitter = { "lsp" },
          columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      ghost_text = { enabled = true },
    },
    fuzzy = { implementation = "lua" },
  },
}
