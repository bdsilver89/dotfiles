return {
  -- NOTE: temporary until heirline is sorted out...
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    enabled = false,
    opts = {
      options = {
        icons_enabled = vim.g.enable_icons,
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  {
    "rebelot/heirline.nvim",
    event = "LazyFile",
    opts = function()
      return {
        opts = {
          disable_winbar_cb = function(args)
            return require("heirline.conditions").buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
              filetype = { "alpha", "dashboard", "oil", "lspinfo" },
            }, args.buf)
          end,
        },
        statuscolumn = require("plugins.heirline.statuscolumn").setup(),
        statusline = require("plugins.heirline.statusline").setup(),
        tabline = require("plugins.heirline.tabline").setup(),
        winbar = require("plugins.heirline.winbar").setup(),
      }
    end,
    config = function(_, opts)
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
          git_del = Utils.get_highlight("GitSignsDelete").fg,
          git_add = Utils.get_highlight("GitSignsAdd").fg,
          git_change = Utils.get_highlight("GitSignsChange").fg,
        }
      end

      require("heirline").setup(opts)
      require("heirline").load_colors(setup_colors())
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("config_heirline_colorscheme", { clear = true }),
        callback = function()
          require("heirline.utils").on_colorscheme(setup_colors)
        end,
      })
    end,
  },
}
