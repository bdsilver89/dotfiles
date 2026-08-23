local add_on_event = require("pack").add_on_event

add_on_event("UIEnter", {
  {
    src = "folke/flash.nvim",
    opts = {},
    on_setup = function()
      vim.keymap.set({ "n", "x", "o" }, "s", function()
        require("flash").jump()
      end, { desc = "Flash" })
      vim.keymap.set("o", "r", function()
        require("flash").treesitter_search()
      end, { desc = "Treesitter Search" })
      vim.keymap.set("o", "R", function()
        require("flash").remote()
      end, { desc = "Remote Flash" })
    end,
  },
})

