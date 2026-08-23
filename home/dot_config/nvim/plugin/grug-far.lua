local add = require("pack").add

add({
  {
    src = "MagicDuck/grug-far.nvim",
    opts = {
      headerMaxWidth = 80,
    },
    on_setup = function()
      vim.keymap.set({ "n", "x" }, "<leader>sr", function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            filesFitler = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end, { desc = "Search and replace" })
    end,
  },
})
