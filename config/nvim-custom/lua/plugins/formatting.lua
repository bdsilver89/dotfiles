return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", "<cmd>Format<cr>", desc = "Format buffer" },
    },
    opts = {
      format_on_save = function(bufnr)
        -- NOTE: vim.g.autoformat and vim.b.autoformat are driven from keymaps to toggle global/buffer autoformatting
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

      vim.api.nvim_create_user_command("FormatInfo", function()
        local buf = vim.api.nvim_get_current_buf()
        local gaf = vim.g.autoformat == nil or vim.g.autoformat
        local baf = vim.b[buf].autoformat
        local enabled = baf ~= nil and baf or gaf == nil or gaf

        local lines = {
          "# Status",
          ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and enabled or "disabled"),
          ("- [%s] buffer **%s**"):format(
            enabled and "x" or " ",
            baf == nil and "inherit" or baf and "enabled" or "disabled"
          ),
        }

        -- local have = false
        --
        -- local get_conform_formatters = function()
        --   local ret = require("conform").list_formatters(buf)
        --   return vim.tbl_map(function(v)
        --     return v.name
        --   end, ret)
        -- end
        --
        -- local get_lsp_formatters = function()
        --   local clients = vim.lsp.get_clients({ bufnr = buf })
        --   local ret = vim.tbl_filter(function(client)
        --     return client.supports_method("textDocument/formatting")
        --       or client.supports_method("textDocument/rangeFormatting")
        --   end, clients)
        --   return vim.tbl_map(function(client)
        --     return client.name
        --   end, ret)
        -- end
        --
        -- local avail_formatters = vim.tbl_map(function(getter)
        --   getter()
        -- end, { get_conform_formatters, get_lsp_formatters })
        --
        -- for _, formatters in ipairs(avail_formatters) do
        --   if #formatters > 0 then
        --     have = true
        --     lines[#lines + 1] = "\n# Active"
        --     for _, line in ipairs(formatters) do
        --       lines[#lines + 1] = ("- [x] **%s**"):format(line)
        --     end
        --   end
        -- end
        --
        -- if not have then
        --   lines[#lines + 1] = "\n***No formatters available for this buffer.***"
        -- end

        vim.notify(
          table.concat(lines, "\n"),
          enabled and vim.log.levels.INFO or vim.log.levels.WARN,
          { title = "Format" }
        )
      end, { desc = "Format info" })
    end,
  },
}
