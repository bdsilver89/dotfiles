return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    keys = {
      { "<leader>cf", "<cmd>Format<cr>", desc = "Format file or range" },
      { "<leader>uf", "<cmd>FormatToggle<cr>", desc = "Toggle formatting (global)" },
      { "<leader>uF", "<cmd>FormatToggleBuf<cr>", desc = "Toggle formatting (buf)" },
    },
    cmd = "ConformInfo",
    event = { "BufWritePre" },
    opts = {
      formatters_by_ft = {},
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

      -- vim.api.nvim_create_user_command("FormatDisable", function(args)
      --   if args.bang then
      --     vim.b.disable_autoformat = true
      --   else
      --     vim.g.disable_autoformat = true
      --   end
      -- end, { desc = "Disable autoformat", bang = true })
      --
      -- vim.api.nvim_create_user_command("FormatEnable", function(args)
      --   vim.b.disable_autoformat = false
      --   vim.g.disable_autoformat = false
      -- end, { desc = "Enable autoformat" })

      vim.api.nvim_create_user_command("FormatToggle", function(args)
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.b.disable_autoformat = vim.g.disable_autoformat
        if vim.g.disable_autoformat then
          require("utils.log").warn("Global autoformat disabled", { title = "Formatting" })
        else
          require("utils.log").info("Global autoformat enabled", { title = "Formatting" })
        end
      end, { desc = "Toggle formatting (global)" })

      vim.api.nvim_create_user_command("FormatToggleBuf", function(args)
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        if vim.b.disable_autoformat then
          require("utils.log").warn("Buffer autoformat disabled", { title = "Formatting" })
        else
          require("utils.log").info("Buffer autoformat enabled", { title = "Formatting" })
        end
      end, { desc = "Toggle formatting (global)" })
    end,
  },
}
