local have_make = vim.fn.executable("make") == 1
local have_cmake = vim.fn.executable("cmake") == 1

return {
  {
    "nvim-telescope/telescope.nvim",
    version = false,
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = have_make and "make"
            or
            "cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = have_make or have_cmake,
        config = function()
        end,
      },
    },
    keys = {
      { "<leader>,",       "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch buffer" },
      { "<leader>/",       "<cmd>Telescope live_grep<cr>",                                desc = "Grep" },
      { "<leader>:",       "<cmd>Telescope command_history<cr>",                          desc = "Command history" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>",                               desc = "Find files" },
    },
    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top" },
          vertical = { mirror = false },
        },
      },
      extensions = {
        fzf = {},
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)

      -- load extensions
      local ok, err = pcall(telescope.load_extension, "fzf")
      if not ok then
        vim.notify("Failed to load `telescope-fzf-native.nvim`", vim.log.levels.ERROR, { title = "Config" })
      end
    end,
  }
}
