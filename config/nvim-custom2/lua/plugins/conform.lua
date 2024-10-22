return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", "<cmd>Format<cr>", desc = "Format buffer" },
    },
    init = function()
      vim.g.autoformat = nil

      vim.keymap.set("n", "<leader>uf", function()
        local state = not (vim.g.autoformat == nil or vim.g.autoformat)
        vim.g.autoformat = state
        vim.b.autoformat = nil
        if state then
          vim.notify("Enabled Autoformat (global)", vim.log.levels.INFO, { title = "Autoformat" })
        else
          vim.notify("Disabled Autoformat (global)", vim.log.levels.WARN, { title = "Autoformat" })
        end
      end, { desc = "Toggle autoformat (global)" })

      vim.keymap.set("n", "<leader>uF", function()
        local buf = vim.api.nvim_get_current_buf()
        local gaf = vim.g.autoformat
        local baf = vim.b[buf].autoformat

        local state
        if baf ~= nil then
          state = not baf
        else
          state = not (gaf == nil or gaf)
        end

        vim.b.autoformat = state
        if state then
          vim.notify("Enabled Autoformat (buffer)", vim.log.levels.INFO, { title = "Autoformat" })
        else
          vim.notify("Disabled Autoformat (buffer)", vim.log.levels.WARN, { title = "Autoformat" })
        end
      end, { desc = "Toggle autoformat (buffer)" })
    end,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        sh = { "shfmt" },
      },
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
