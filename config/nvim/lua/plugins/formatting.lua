return {
  "stevearc/conform.nvim",
  dependencies = {
    "mason-tool-installer.nvim",
  },
  event = "BufWritePre",
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      desc = "Format",
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    vim.g.autoformat = true

    vim.keymap.set("n", "<leader>uf", function()
      local state = not vim.g.autoformat
      vim.g.autoformat = state
      vim.notify(
        string.format("***%s autoformatting***", state and "Enabled" or "Disabled"),
        state and vim.log.levels.INFO or vim.log.levels.WARN
      )
    end, { desc = "Toggle Autoformatting" })

    vim.api.nvim_create_user_command("ToggleFormat", function()
      local state = not vim.g.autoformat
      vim.g.autoformat = state
      vim.notify(
        string.format("***%s auto-formatting***", state and "Enabled" or "Disabled"),
        state and vim.log.levels.INFO or vim.log.levels.WARN
      )
    end, { desc = "Toggle conform.nvim auto-formatting", nargs = 0 })

    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      require("conform").format({ async = true, lsp_format = "fallback", range = range })
    end, { range = true })
  end,
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
    },
    formatters = {},
    format_on_save = function()
      if not vim.g.autoformat then
        return nil
      end
      return {}
    end,
  },
}
