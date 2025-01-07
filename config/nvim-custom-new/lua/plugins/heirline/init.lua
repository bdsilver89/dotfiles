local function setup_colors()
  local Utils = require("heirline.utils")

  return {
    bright_bg = Utils.get_highlight("Folded").bg,
    bright_fg = Utils.get_highlight("Folded").fg,
    red = Utils.get_highlight("DiagnosticError").fg,
    dark_red = Utils.get_highlight("DiffDelete").bg,
    green = Utils.get_highlight("String").fg,
    blue = Utils.get_highlight("Function").fg,
    gray = Utils.get_highlight("NonText").fg,
    orange = Utils.get_highlight("Constant").fg,
    purple = Utils.get_highlight("Statement").fg,
    cyan = Utils.get_highlight("Special").fg,
    diag_warn = Utils.get_highlight("DiagnosticWarn").fg,
    diag_error = Utils.get_highlight("DiagnosticError").fg,
    diag_hint = Utils.get_highlight("DiagnosticHint").fg,
    diag_info = Utils.get_highlight("DiagnosticInfo").fg,
    git_del = Utils.get_highlight("diffRemoved").fg,
    git_add = Utils.get_highlight("diffAdded").fg,
    git_change = Utils.get_highlight("diffChanged").fg,
  }
end

return {
  {
    "rebelot/heirline.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = function()
      return {
        statusline = require("plugins.heirline.statusline"),
        -- winbar = {},
        -- tabline = {},
        -- statuscolumn = require("plugins.heirline.statuscolumn"),
        opts = {
          disable_winbar_cb = function(args)
            if vim.bo[args].filetype == "NvimTree" then
              return
            end
            return require("heirline.conditions").buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix" },
              filetype = { "^git.*", "fugitive" },
            }, args.buf)
          end,
          colors = setup_colors,
        },
      }
    end,
    config = function(_, opts)
      require("heirline").setup(opts)

      -- vim.o.statuscolumn = require("heirline").eval_statuscolumn()

      local group = vim.api.nvim_create_augroup("config_heirline", { clear = true })

      vim.cmd([[au config_heirline FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
          require("heirline.utils").on_colorscheme(setup_colors)
        end,
      })
    end,
  },
}
