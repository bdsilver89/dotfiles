return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    keys = {
      { "<leader>cf", "<cmd>Format<cr>", desc = "Format file or range" },
    },
    cmd = "ConformInfo",
    event = { "BufWritePre" },
    opts = {
      formatters_by_ft = {
        -- zig = { "zigformat" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_fallback = true }
      end,
    },
    init = function()
      vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_fallback = true, range = range })
      end, { range = true, desc = "Format" })

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "Disable autoformat", bang = true })

      vim.api.nvim_create_user_command("FormatEnable", function(args)
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Enable autoformat" })
    end,
    -- config = function(_, opts)
    --   require("conform").setup(opts)
    -- end,
  },
}
