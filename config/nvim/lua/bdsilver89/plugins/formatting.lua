return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      format = {
        lsp_fallback = true,
      },
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        python = { "black" },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
          vim.notify("Disabled autoformat for buffer", vim.log.levels.WARN, { title = "Conform" })
        else
          vim.g.disable_autoformat = true
          vim.notify("Disabled autoformat globally", vim.log.levels.WARN, { title = "Conform" })
        end
      end, {
        desc = "Disable autoformat on save",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function(args)
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
        vim.notify("Enabled autoformat", vim.log.levels.INFO, { title = "Conform" })
      end, { desc = "Enable autoformat" })
    end,
  }
}
