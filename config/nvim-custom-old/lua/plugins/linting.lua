return {
  {
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    opts = {
      linters_by_ft = {}
    },
    config = function(_, opts)
      local lint = require("lint")

      lint.linters_by_ft = opts.linters_by_ft

      local function valid_linters(ctx, linters)
        if not linters then
          return {}
        end
        return vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          return linter
            and vim.fn.executable(linter.cmd) == 1
            and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, linters)
      end

      local orig_resolve_linter_by_ft = lint._resolve_linter_by_ft
      lint._resolve_linter_by_ft = function(...)
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")

        local linters = valid_linters(ctx, orig_resolve_linter_by_ft(...))
        if not linters[1] then
          linters = valid_linters(ctx, lint.linters_by_ft["_"])
        end

        return linters
      end

      lint.try_lint() -- start linter immediately
      local timer = vim.loop.new_timer()
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
        group = vim.api.nvim_create_augroup("config_linter", { clear = true }),
        callback = function ()
          timer:start(100, 0, function()
            timer:stop()
            vim.schedule(lint.try_lint)
          end)
        end
      })
    end,
  }
}
