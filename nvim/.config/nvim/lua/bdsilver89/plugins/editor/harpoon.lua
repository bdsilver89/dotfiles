return {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  dependencies = {
    "nvim-telescope/telescope.nvim"
  },
  keys = {
    { "<leader>ha", function() require("harpoon.mark").add_file() end,        desc = "Add file" },
    { "<leader>hu", function() require("harpoon.ui").toggle_quick_menu() end, desc = "UI toggle" },
    { "<leader>h1", function() require("harpoon.ui").nav_file(1) end,         desc = "Nav file 1" },
    { "<leader>h2", function() require("harpoon.ui").nav_file(2) end,         desc = "Nav file 2" },
    { "<leader>h3", function() require("harpoon.ui").nav_file(3) end,         desc = "Nav file 3" },
    { "<leader>h4", function() require("harpoon.ui").nav_file(4) end,         desc = "Nav file 4" },
    { "<leader>h5", function() require("harpoon.ui").nav_file(5) end,         desc = "Nav file 5" },
    { "<leader>h6", function() require("harpoon.ui").nav_file(6) end,         desc = "Nav file 6" },
    { "<leader>h7", function() require("harpoon.ui").nav_file(7) end,         desc = "Nav file 7" },
    { "<leader>h8", function() require("harpoon.ui").nav_file(8) end,         desc = "Nav file 8" },
    { "<leader>h9", function() require("harpoon.ui").nav_file(9) end,         desc = "Nav file 9" },
    { "<leader>sm", "<cmd>Telescope harpoon marks<cr>",                       desc = "Harpoon marks" },
  },
  init = function()
    require("telescope").load_extension("harpoon")
  end,
}
