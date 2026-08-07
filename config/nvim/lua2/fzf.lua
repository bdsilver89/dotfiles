local pack = require("pack")

pack.add({
  {
    src = "ibhagwan/fzf-lua",
    module_name = "fzf-lua",
    opts = {
    },
    on_setup = function()
      local fzf = require("fzf-lua")

      vim.keymap.set("n", "<leader><space>", fzf.files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Live grep" })
    end,
  },
})
