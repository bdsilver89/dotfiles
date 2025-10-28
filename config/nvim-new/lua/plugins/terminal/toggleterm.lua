return {
  "akinsho/toggleterm.nvim",
  cmd = {
    "ToggleTerm",
    "TermNew",
    "TermSelect",
    "ToggleTermToggleAll",
    "ToggleTermSendCurrentLine",
    "ToggleTermSendVisualLines",
    "ToggleTermSendVisualSelection",
  },
  -- stylua: ignore
  keys = {
    { "<leader>tf", "<cmd>TermNew direction=float<cr>",         desc = "New terminal (float)" },
    { "<leader>tF", "<cmd>ToggleTerm direction=float<cr>",      desc = "Toggle terminal (float)" },
    { "<leader>tv", "<cmd>TermNew direction=vertical<cr>",      desc = "New terminal (vertical)" },
    { "<leader>tV", "<cmd>ToggleTerm direction=vertical<cr>",   desc = "Toggle terminal (vertical)" },
    { "<leader>th", "<cmd>TermNew direction=horizontal<cr>",    desc = "New terminal (horizontal)" },
    { "<leader>tH", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle terminal (horizontal)" },
    { "<leader>ts", "<cmd>TermSelect<cr>",                      desc = "Select terminal" },
    { "<leader>tt", "<cmd>ToggleTermToggleAll<cr>",             desc = "Toggle/Close all terminals" },
    {
      "<leader>gg",
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
        lazygit:toggle()
      end,
      desc = "Lazygit"
    },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return vim.o.lines * 0.4
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.5
      end
    end,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_terminals = false,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    autochdir = true,
    highlights = {
      NormalFloat = {
        link = "Normal",
      },
      FloatBorder = {
        link = "FloatBorder",
      },
    },
    float_opts = {
      border = "rounded",
      height = math.ceil(vim.o.lines * 1.0 - 4),
      width = math.ceil(vim.o.columns * 0.8),
      winblend = 0,
    },
  },
}
