require("blink.cmp").setup({
  snippets = {
    preset = "default",
  },
  completion = {
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
    menu = {
      border = "none",
      draw = {
        treesitter = { "lsp" },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = {
      enabled = true,
    },
  },
  sources = {
    -- compat = {},
    default = { "lsp", "path", "snippets", "buffer" },
  },
  cmdline = {
    enabled = true,
    keymap = {
      preset = "cmdline",
    },
    completion = {
      list = {
        selection = {
          preselect = false,
        },
      },
      menu = {
        auto_show = function(_ctx)
          return vim.fn.getcmdtype() == ":"
        end,
      },
      ghost_text = {
        enabled = true,
      },
    },
  },
  keymap = {
    preset = "default",
    ["<cr>"] = { "accept", "fallback" },
    ["<tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<s-tab>"] = { "select_prev", "fallback" },
  },
})
