local add_on_event = require("pack").add_on_event

add_on_event("UIEnter", {
  {
    src = "stevearc/quicker.nvim",
    opts = {
      vert = require('icons').misc.vertical_bar,
    },
    on_setup = function()
      local quicker = require("quicker")

      vim.keymap.set("n", "<leader>xq", function()
        quicker.toggle()
      end, { desc = "Toggle quickfix" })
      vim.keymap.set("n", "<leader>xl", function()
        quicker.toggle({ loclist = true })
      end, { desc = "Toggle loclist" })
      vim.keymap.set("n", "<leader>xd", function()
        if quicker.is_open() then
          quicker.close()
        else
          vim.diagnostic.setqflist()
        end
      end, { desc = "Toggle diagnostics" })
      vim.keymap.set("n", "<", function()
        quicker.expand({ before = 2, after = 2, add_to_existing = true })
      end, { desc = "Expand context" })
      vim.keymap.set("n", ">", function()
        quicker.collapse()
      end, { desc = "Collapse context" })
    end
  },
})
