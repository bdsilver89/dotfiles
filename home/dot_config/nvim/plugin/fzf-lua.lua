local add = require("pack").add

add({
  {
    src = "ibhagwan/fzf-lua",
    opts = function()
      local fzf = require("fzf-lua")

      fzf.config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"

      return {
        ui_select = {},
      }
    end,
    on_setup = function()
      vim.keymap.set("n", "<leader><space>", "<cmd>FzfLua files<cr>")
      vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>")
      vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>")
      vim.keymap.set("n", "<leader>:", "<cmd>FzfLua command_history<cr>")
    end,
  }
})
