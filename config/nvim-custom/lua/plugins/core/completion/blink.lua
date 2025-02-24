vim.g.blink_main = false

return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = "rafamadriz/friendly-snippets",
    version = not vim.g.blink_main and "*",
    build = vim.g.blink_main and "cargo build --release",
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.default",
    },
    opts = {
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
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
      signature = {
        window = {
          border = "rounded",
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        cmdline = {},
      },
      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
      },
    },
    -- config = function(_, opts)
    --   if not opts.keymap["<Tab>"] then
    --     if opts.keymap.preset == "super-tab" then
    --       opts.keymap["<Tab>"] = {
    --         require("blink.cmp.keymap.presets")["super-tab"]["<Tab>"][1],
    --         require("plugins.core.completion.utils").map({ "snippet_forward" }),
    --         "fallback",
    --       }
    --     else
    --       opts.keymap["<Tab>"] = {
    --         require("plugins.core.completion.utils").map({ "snippet_forward" }),
    --         "fallback",
    --       }
    --     end
    --   end
    --
    --   require("blink.cmp").setup(opts)
    -- end,
  },
}
