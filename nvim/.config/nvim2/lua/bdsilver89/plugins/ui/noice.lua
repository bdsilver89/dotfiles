return {
  "folke/noice.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<s-enter>",
      function()
        require("noice").redirect(vim.fn.getcmdline())
      end,
      mode = "c",
      desc = "Redirect cmdline",
    },
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice last message" },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice history" },
    { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice all" },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Noice dismiss all" },
    {
      "<c-f>",
      function()
        if not require("noice.lsp").scroll(4) then
          return "<c-f>"
        end
      end,
      silent = true,
      expr = true,
      mode = { "i", "n", "s" },
      desc = "Scroll forward",
    },
    {
      "<c-b>",
      function()
        if not require("noice.lsp").scroll(-4) then
          return "<c-b>"
        end
      end,
      silent = true,
      expr = true,
      mode = { "i", "n", "s" },
      desc = "Scroll backward",
    },
  },
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.sytlize_markdown"] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
  },
}
