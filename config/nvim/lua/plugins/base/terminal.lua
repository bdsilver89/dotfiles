return {
  {
    "akinsho/toggleterm.nvim",
    enabled = false,
    keys = {
      { "<leader>ct", "<cmd>ToggleTerm<cr>", desc = "Toggleterm", mode = "n" },
      -- { "<leader>Tg", "<cmd>TermExec cmd=lazygit<cr>", desc = "Lazygit", mode = "n" },
      -- { "<leader>Td", "<cmd>TermExec cmd=lazydocker<cr>", desc = "Lazydocker", mode = "n" },
    },
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = 20,
      hide_numbers = true,
      -- open_mapping = [[<leader>ct]],
      shade_filetypes = {},
      shade_terminals = false,
      shading_factor = 0.3,
      start_in_insert = true,
      persist_size = true,
      direction = "horizontal",
      winbar = {
        enabled = true,
        name_formatter = function(term)
          return term.name
        end,
      },
    },
  },
}
