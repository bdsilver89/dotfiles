return {
  "akinsho/toggleterm.nvim",
  keys = {
    { "[[<c-\\>]]" },
    { "<leader>0", "<cmd2ToggleTerm<cr>", desc = "Terminal #2" },
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
    }
  },
}
