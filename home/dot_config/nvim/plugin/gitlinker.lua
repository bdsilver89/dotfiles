local add = require("pack").add

add({
  {
    src = "linrongbin16/gitlinker.nvim",
    on_setup = function()
      vim.keymap.set(
        { "n", "v" },
        "<leader>gym",
        "<cmd>GitLink default_branch<cr>",
        { desc = "Copy line URL (main branch)" }
      )
      vim.keymap.set(
        { "n", "v" },
        "<leader>gyb",
        "<cmd>GitLink current_branch<cr>",
        { desc = "Copy line URL (current branch)" }
      )
      vim.keymap.set({ "n", "v" }, "<leader>gyc", "<cmd>GitLink<cr>", { desc = "Copy line URL (commit)" })
    end,
  },
})
