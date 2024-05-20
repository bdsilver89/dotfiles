return {
  {
    "numToStr/Comment.nvim",
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        lazy = true,
        opts = {
          enable_autocmd = false
        },
      },
    },
    opts = function(_, opts)
      local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      if commentstring_avail then
        opts.pre_hook = commentstring.create_pre_hook()
      end
    end,
  },
}
