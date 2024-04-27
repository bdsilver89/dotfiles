return {
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>f",
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        desc = "Format buffer"
      },
    },
    opts = {
      notify_on_error = false,
      formatters_by_ft = {
        lua = { "stylua" },
      },
      format_on_save = function(buffer)
      end,
    }
  }
}
