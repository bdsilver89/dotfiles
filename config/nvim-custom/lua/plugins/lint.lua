return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_fy = {
        lua = { "stylua" },
      }

      local group = vim.api.nvim_create_augroup("config_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = group,
        callback = function()
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })
    end,
    --     opts = {
    --       events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    --       linters_by_ft = {},
    --     },
    --     config = function(_, opts)
    --       local lint = require("lint")
    --       lint.linters_by_ft = opts.linters_by_ft
    --
    --       local M = {}
    --       function M.debounce(ms, fn)
    --         local timer = vim.uv.new_timer()
    --         return function(...)
    --           local argv = { ... }
    --           timer:start(ms, 0, function()
    --             timer:stop()
    --             vim.schedule_wrap(fn)(unpack(argv))
    --           end)
    --         end
    --       end
    --
    --       function M.lint()
    --         local names = lint._resolve_linter_by_ft(vim.bo.filetype)
    --
    --         names = vim.list_extend({}, names)
    --         if #names == 0 then
    --           vim.list_extend(names, lint.linters_by_ft["_"] or {})
    --         end
    --         vim.list_extend(names, lint.linters_by_ft["*"] or {})
    --
    --         local ctx = { filename = vim.api.nvim_buf_get_name(0) }
    --         ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
    --         names = vim.tbl_filter(function(name)
    --           local linter = lint.linters[name]
    --           if not linter then
    --             vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
    --           end
    --           return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
    --         end, names)
    --
    --         if #names > 0 then
    --           lint.try_lint(names)
    --         end
    --       end
    --
    --       vim.api.nvim_create_autocmd(opts.events, {
    --         group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
    --         callback = M.debounce(100, M.lint),
    --       })
    --     end,
  },
}
