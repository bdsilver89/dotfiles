local pack = require("pack")

pack.add_on_event("UIEnter", {
  {
    src = "stevearc/oil.nvim",
    module_name = "oil",
    opts = {
      skip_confirm_for_simple_edits = true,
    },
    on_setup = function()
      vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })
    end,
  },
})
