return {
  {
    "rebelot/heirline.nvim",
    event = "BufEnter",
    opts = function()
      return {
        opts = {
          disable_winbar_cb = function(args)
            return require("heirline.conditions").buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
              filetype = { "alpha", "codecompanion", "oil", "lspinfo", "toggleterm" },
            }, args.buf)
          end,
        },
        statuscolumn = require("bdsilver89.plugins.heirline.statuscolumn").setup(),
        statusline = require("bdsilver89.plugins.heirline.statusline").setup(),
        tabline = require("bdsilver89.plugins.heirline.tabline").setup(),
        winbar = require("bdsilver89.plugins.heirline.winbar").setup(),
      }
    end,
    config = function(_, opts)
      local Utils = require("heirline.utils")
      local function setup_colors()
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
          -- statusline_bg = Utils.get_highlight("Statusline").bg,
          -- statusline_fg = Utils.get_highlight("Statusline").fg,
          -- tabline_bg = Utils.get_highlight("Tabline").bg,
          -- tabline_fg = Utils.get_highlight("Tabline").fg,
        }
      end

      require("heirline").setup(opts)
      require("heirline").load_colors(setup_colors())

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("config_heirline_colors", { clear = true }),
        callback = function()
          Utils.on_colorscheme(setup_colors)
        end,
      })
    end,
  }
}
