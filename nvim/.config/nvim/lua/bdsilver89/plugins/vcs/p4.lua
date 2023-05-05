return {
  {
    "ngemily/vim-vp4",
    event = { "BufReadPre", "BufNewFile" },
    cond = function()
      if vim.fn.executable("p4") == 1 then
        return true
      end
      return false
    end,
    config = function(_, opts)
      vim.g.vp4_prompt_on_write = 1
    end,
    keys = {
      { "<leader>pa", "<cmd>Vp4Annotate<cr>", desc = "P4 annotate" },
      { "<leader>pd", "<cmd>Vp4Diff<cr>",     desc = "P4 diff" },
    },
  },
}
