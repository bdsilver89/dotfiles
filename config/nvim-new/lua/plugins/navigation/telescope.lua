return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      enabled = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  keys = {
    { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>,", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
  },
  opts = {},
}
