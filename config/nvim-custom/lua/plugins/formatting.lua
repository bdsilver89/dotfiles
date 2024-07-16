return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", "<cmd>Format<cr>", desc = "Format buffer" },
      {
        "<leader>uf",
        function()
          if vim.b.autoformat == nil then
            if vim.g.autoformat == nil then
              vim.g.autoformat = true
            end
            vim.b.autoformat = vim.g.autoformat
          end
          vim.b.autoformat = not vim.b.autoformat
          if vim.b.autoformat then
            vim.notify("Buffer autoformatting enabled", vim.log.levels.INFO, { title = "Format" })
          else
            vim.notify("Buffer autoformatting disabled", vim.log.levels.WARN, { title = "Format" })
          end
        end,
        desc = "Toggle autoformat (buffer)",
      },
      {
        "<leader>uF",
        function()
          if vim.g.autoformat == nil then
            vim.g.autoformat = true
          end
          vim.g.autoformat = not vim.g.autoformat
          vim.b.autoformat = nil
          if vim.g.autoformat then
            vim.notify("Global autoformatting enabled", vim.log.levels.INFO, { title = "Format" })
          else
            vim.notify("Global autoformatting disabled", vim.log.levels.WARN, { title = "Format" })
          end
        end,
        desc = "Toggle autoformat (global)",
      },
    },
    opts = {
      format_on_save = function(bufnr)
        if vim.g.autoformat == nil then
          vim.g.autoformat = true
        end
        local autoformat = vim.b[bufnr].autoformat
        if autoformat == nil then
          autoformat = vim.g.autoformat
        end
        if autoformat then
          return { timout_ms = 500, lsp_fallback = true }
        end
      end,
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
        require("conform").format({ async = true, lsp_fallback = true, range = range })
      end, { desc = "Format buffer", range = true })
    end,
  },
}
