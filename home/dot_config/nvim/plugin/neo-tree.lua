local add = require("pack").add

add({
  {
    src = "nvim-lua/plenary.nvim",
    setup = false,
  },
  {
    src = "MunifTanjim/nui.nvim",
    setup = false,
  },
  {
    src = "nvim-neo-tree/neo-tree.nvim",
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      source_selector = {
        winbar = true,
        content_layout = "center",
      },
    },
    on_setup = function()
      vim.keymap.set("n", "<leader>fe", function()
        require("neo-tree.command").execute({ toggle = true })
      end, { desc = "File explorer" })
      vim.keymap.set("n", "<leader>e", function()
        require("neo-tree.command").execute({ toggle = true })
      end, { desc = "File explorer" })
      vim.keymap.set("n", "<leader>be", function()
        require("neo-tree.command").execute({ toggle = true, source = "buffers" })
      end, { desc = "Buffer explorer" })
      vim.keymap.set("n", "<leader>ge", function()
        require("neo-tree.command").execute({ toggle = true, source = "git_status" })
      end, { desc = "Git explorer" })
    end,
  },
})
