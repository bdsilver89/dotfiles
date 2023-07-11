return {
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  --stylua: ignore
  keys = {
    { "<leader>ja", function() require("harpoon.mark").add_file() end, desc = "Add file" },
    { "<leader>jm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Menu" },
    { "<leader>j1", function() require("harpoon.ui").nav_file(1) end, desc = "Nav file 1" },
    { "<leader>j2", function() require("harpoon.ui").nav_file(2) end, desc = "Nav file 2" },
    { "<leader>j3", function() require("harpoon.ui").nav_file(3) end, desc = "Nav file 3" },
    { "<leader>j4", function() require("harpoon.ui").nav_file(4) end, desc = "Nav file 4" },
    { "<leader>j5", function() require("harpoon.ui").nav_file(5) end, desc = "Nav file 5" },
    { "<leader>j6", function() require("harpoon.ui").nav_file(6) end, desc = "Nav file 6" },
    { "<leader>j7", function() require("harpoon.ui").nav_file(7) end, desc = "Nav file 7" },
    { "<leader>j8", function() require("harpoon.ui").nav_file(8) end, desc = "Nav file 8" },
    { "<leader>j9", function() require("harpoon.ui").nav_file(9) end, desc = "Nav file 9" },
    { "<leader>sj", "<cmd>Telescope harpoon marks<cr>", desc = "Jumps" },
  },
    opts = {
      global_settings = {
        save_on_toggle = true,
        enter_on_sendcmd = true,
      },
    },
    config = function(_, opts)
      require("harpoon").setup(opts)
      require("telescope").load_extension("harpoon")
    end,
  },
}
