-- TODO: lots of options to configure after settings up LSP and diagnostics
return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Buffer toggle pin" },
    { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Delete non-pinned buffers" },
  },
  opts = {
    options = {
      -- close_command = function(n) end,
      -- diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      -- diagnostics_indicator = function(_, _, diag)
      -- end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
}
