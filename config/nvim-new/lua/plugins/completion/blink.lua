return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      dependencies = "rafamadriz/friendly-snippets",
      build = "make install_jsregexp",
    },
  },
  opts = {
    cmdline = {
      completion = {
        menu = {
          auto_show = function(_)
            return vim.fn.getcmdtype() == ":"
          end,
        },
      },
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        draw = {
          treesitter = { "lsp" },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay = 200,
      },
      ghost_text = {
        enabled = true,
      },
    },
    keymap = {
      preset = "enter",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    snippets = {
      preset = "luasnip",
    },
    fuzzy = { implementation = "prefer_rust" },
  },
}
