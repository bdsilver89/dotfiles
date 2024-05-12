return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "Format", "FormatEnable", "FormatDisable" },
    keys = {
      {
        "<leader>cf",
        "<cmd>Format<cr>",
        mode = { "n", "v" },
        desc = "Format",
      },
    },
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
      formatters_by_ft = {},
    },
    config = function(_, opts)
      require("conform").setup(opts)

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        if not vim.g.disable_autoformat and not vim.b.disable_autoformat then
          require("conform").format({ async = true, lsp_fallback = true, range = range })
          vim.notify("Formatted", vim.log.levels.INFO, { title = "Conform" })
        else
          vim.notify("Formatter is bypassed", vim.log.levels.WARN, { title = "Conform" })
        end
      end, { range = true, desc = "Format" })

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
  },
}
