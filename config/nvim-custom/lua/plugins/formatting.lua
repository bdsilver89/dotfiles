return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  dependencies = {
    "mason.nvim",
  },
  cmd = {
    "Format",
    "ConformInfo",
  },
  -- stylua: ignore
  keys = {
    { "<leader>cf", function() require("conform").format() end, desc = "Format" },
    {
      "<leader>uf",
      function()
        if vim.g.disable_autoformat == nil or vim.g.disable_autoformat == false then
          vim.g.disable_autoformat = true
          vim.notify("*** Disabled global autoformat on save ***", vim.log.levels.WARN)
        else
          vim.g.disable_autoformat = false
          vim.notify("*** Enabled global autoformat on save ***", vim.log.levels.INFO)
        end
      end,
      desc = "Auto Format (Global)"
    },
    {
      "<leader>uF",
      function()
        if vim.b.disable_autoformat == nil or vim.b.disable_autoformat == false then
          vim.b.disable_autoformat = true
          vim.notify("*** Disabled buffer autoformat on save ***", vim.log.levels.WARN)
        else
          vim.g.disable_autoformat = false
          vim.notify("*** Enabled buffer autoformat on save ***", vim.log.levels.INFO)
        end
      end,
      desc = "Auto Format (Buffer)"
    },
  },
  init = function()
    vim.g.disble_autformat = false

    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    -- "Format" user command
    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.count ~= 1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      require("conform").format({ async = true, lsp_format = "fallback", range = range })
    end, { desc = "Format buffer or range", range = true })

    -- "FormatDisable" user command
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
        vim.notify("*** Disabled buffer autoformat on save ***", vim.log.levels.WARN)
      else
        vim.g.disable_autoformat = true
        vim.notify("*** Disabled global autoformat on save ***", vim.log.levels.WARN)
      end
    end, { desc = "Disable autoformat on save", bang = true })

    -- "FormatEnable" user command
    vim.api.nvim_create_user_command("FormatEnable", function(args)
      if args.bang then
        vim.b.disable_autoformat = false
        vim.notify("*** Disabled buffer autoformat on save ***", vim.log.levels.INFO)
      else
        vim.g.disable_autoformat = false
        vim.notify("*** Enabled global autoformat on save ***", vim.log.levels.INFO)
      end
    end, { desc = "Enable autoformat on save", bang = true })
  end,
  opts = {
    default_format_options = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = "fallback",
    },
    formatters = {},
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "goimports", "gofumpt" },
      python = { "black" },
      sh = { "shfmt" },

      css = { "prettier" },
      html = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      less = { "prettier" },
      markdown = { "prettier" },
      scss = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      vue = { "prettier" },
      yaml = { "prettier" },
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 5000, lsp_format = "fallback" }
    end,
  },
}
