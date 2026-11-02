vim.pack.add({
  "https://github.com/akinsho/bufferline.nvim",
})

require("bufferline").setup({
  options = {
    show_close_icons = false,
    show_buffer_close_icons = false,
    truncate_names = false,
    indiciator = { style = "underline " },
    -- TODO: close_command use bufremove
    diagnostics = "nvim_lsp",
  },
})
