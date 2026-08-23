local add = require("pack").add

add({
  {
    src = "folke/which-key.nvim",
    opts = {
      preset = "helix",
      spec = {
        {
          mode = { "n", "x" },
          { "<leader>b", group = "buffer" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>f", group = "find/file" },
          { "<leader>g", group = "git" },
          { "<leader>h", group = "hunk" },
          { "<leader>s", group = "search" },
          { "<leader>q", group = "quit/session" },
          { "<leader>t", group = "test" },
          { "<leader>x", group = "diagnostics" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "z", group = "fold" },
        },
      },
    },
  },
})
