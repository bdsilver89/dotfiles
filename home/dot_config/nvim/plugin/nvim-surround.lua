local add_on_event = require("pack").add_on_event

add_on_event("UIEnter", {
  {
    src = "kylechui/nvim-surround",
    on_setup = function()
      vim.keymap.set("n", "yz", "<Plug>(nvim-surround-normal)", {
        desc = "Add surrounding pair around a motion",
      })
      vim.keymap.set("n", "yzz", "<Plug>(nvim-surround-cur)", {
        desc = "Add surrounding pair around current line",
      })
      vim.keymap.set("x", "Z", "<Plug>(nvim-surround-visual)", {
        desc = "Add surrounding pair around visual selection",
      })
      vim.keymap.set("n", "ds", "<Plug>(nvim-surround-delete)", {
        desc = "Delete surrounding pair",
      })
      vim.keymap.set("n", "cs", "<Plug>(nvim-surround-change)", {
        desc = "Change surrounding pair",
      })
    end,
  },
})

vim.g.nvim_surround_no_mappings = true
