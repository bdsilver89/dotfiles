local blink_main = false
local blink_lua = false

return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = not blink_main and "*",
  build = blink_main and "cargo --build release",
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      "saghen/blink.compat",
      optional = true,
      opts = {},
      version = not blink_main and "*",
    },
  },
  opts = {
    snippets = {
      expand = function(snippet, _)
        return require("cmp_utils").expand(snippet)
      end,
    },
    cmdline = { enabled = false },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = blink_lua and "lua" or "prefer_rust" },
    signature = {
      window = {
        border = "rounded",
      },
    },
    keymap = {
      preset = "enter",
      ["<C-y>"] = { "select_and_accept" },
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        border = "rounded",
        draw = {
          treesitter = { "lsp" },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = "rounded",
        },
      },
      ghost_text = {
        enabled = true,
      },
    },
  },
  config = function(_, opts)
    if not opts.keymap["<Tab>"] then
      if opts.keymap.preset == "super-tab" then
        opts.keymap["<tab>"] = {
          require("blink.cmp.keymap.presets")["super-tab"]["<tab>"][1],
          require("cmp_utils").map({ "snippet_forward", "ai_accept" }),
          "fallback",
        }
      else
        opts.keymap["<tab>"] = {
          require("cmp_utils").map({ "snippet_forward", "ai_accept" }),
          "fallback",
        }
      end
    end

    require("blink.cmp").setup(opts)
  end,
}
