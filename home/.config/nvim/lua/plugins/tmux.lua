return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><c-u>TmuxNavigateLeft<cr>", desc = "Window left" },
      { "<c-j>", "<cmd><c-u>TmuxNavigateDown<cr>", desc = "Window down" },
      { "<c-k>", "<cmd><c-u>TmuxNavigateUp<cr>", desc = "Window up" },
      { "<c-l>", "<cmd><c-u>TmuxNavigateRight<cr>", desc = "Window right" },
      { "<c-\\>", "<cmd><c-u>TmuxNavigatePRevious<cr>", desc = "Window previous" },
    },
  },
}
