return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      "mason.nvim",
    },
    cmd = {
      "Format",
      "FormatEnable",
      "FormatDisable",
      "ConformInfo",
    },
    -- stylua: ignore
    keys = {
      { "<leader>cf", function() require("conform").format() end, desc = "Format" },
      -- { "<leader>uf", desc = "Auto Format (Global)" },
      -- { "<leader>uF", desc = "Auto Format (Buffer)"},
    },
    event = "BufWritePre",
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    opts = {
      default_format_options = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters = {},
      formatters_by_ft = {},
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 5000, lsp_format = "fallback" }
      end,
    },
    config = function(_, opts)
      require("conform").setup(opts)

      -- "Format" user command
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

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
          vim.notify("*** Disabled buffer autoformat on save ***", vim.log.levels.WARN)
        else
          vim.g.disable_autoformat = true
          vim.notify("*** Disabled global autoformat on save ***", vim.log.levels.WARN)
        end
      end, { desc = "Disable autoformat on save", bang = true })

      vim.api.nvim_create_user_command("FormatEnable", function(args)
        if args.bang then
          vim.b.disable_autoformat = false
          vim.notify("*** Enabled buffer autoformat on save ***", vim.log.levels.INFO)
        else
          vim.g.disable_autoformat = false
          vim.notify("*** Enabled global autoformat on save ***", vim.log.levels.INFO)
        end
      end, { desc = "Enable autoformat on save", bang = true })

      -- Snacks.toggle({
      --   name = "Auto Format (Global)",
      --   get = function()
      --     return vim.g.autoformat == nil or vim.g.autoformat
      --   end,
      --   set = function(state)
      --     enable(state)
      --   end,
      -- }):map("<leader>uf")
      --
      -- Snacks.toggle({
      --   name = "Auto Format (Buffer)",
      --   get = function()
      --     return enabled()
      --   end,
      --   set = function(state)
      --     enable(state, true)
      --   end,
      -- }):map("<leader>uF")
    end,
  },
}
