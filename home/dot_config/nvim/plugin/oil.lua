local add = require("pack").add

add({
  {
    src = "stevearc/oil.nvim",
    on_setup = function()
      vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })
    end,
  },
})
