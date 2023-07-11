return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "[[<c-\\>]]" },
      { "<leader>1", "<cmd>1ToggleTerm<cr>", desc = "Terminal #1" },
      { "<leader>2", "<cmd>2ToggleTerm<cr>", desc = "Terminal #2" },
      { "<leader>3", "<cmd>3ToggleTerm<cr>", desc = "Terminal #3" },
      { "<leader>4", "<cmd>4ToggleTerm<cr>", desc = "Terminal #4" },
    },
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = 20,
      hide_numbers = true,
      open_mapping = [[<c-\\>]],
      shade_filetypes = {},
      shade_terminals = false,
      shading_factor = 0.3,
      start_in_insert = true,
      persist_size = true,
      direction = "float",
      winbar = {
        enabled = true,
        name_formatter = function(term)
          return term.name
        end,
      },
    },
  },
}
