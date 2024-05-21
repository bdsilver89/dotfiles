return {
  {
    "rebelot/heirline.nvim",
    event = "LazyFile",
    opts = function()
      local Components = require("plugins.heirline.components")

      return {
        opts = {
          -- colors = setup_colors,
          disable_winbar_cb = function(args)
            return require("heirline.conditions").buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
              filetype = { "alpha", "dashboard", "oil", "lspinfo" },
            }, args.buf)
          end,
        },
        statuscolumn = {
          condition = function()
            return not require("heirline.conditions").buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
              filetype = { "alpha", "dashboard", "harpoon", "oil", "lspinfo", "toggleterm" },
            })
          end,
          Components.signcolumn(),
          Components.fill(),
          Components.numbercolumn(),
          Components.foldcolumn(),
          Components.gitsigncolumn(),
        },
        -- statusline = {},
        -- tabline = {},
        -- winbar = {},
      }
    end,
    config = function(_, opts)
      local function setup_colors()
        local Utils = require("heirline.utils")

        local Normal = Utils.get_highlight("Normal")
        local Comment = Utils.get_highlight("Comment")
        local Error = Utils.get_highlight("Error")
        local StatusLine = Utils.get_highlight("StatusLine")
        local TabLine = Utils.get_highlight("TabLine")
        local TabLineFill = Utils.get_highlight("TabLineFill")
        local TabLineSel = Utils.get_highlight("TabLineSel")
        local WinBar = Utils.get_highlight("WinBar")
        local WinBarNC = Utils.get_highlight("WinBarNC")
        local Conditional = Utils.get_highlight("Conditional")
        local String = Utils.get_highlight("String")
        local TypeDef = Utils.get_highlight("TypeDef")
        local NvimEnvironmentName = Utils.get_highlight("NvimEnvironmentName")
        local GitSignsAdd = Utils.get_highlight("GitSignsAdd")
        local GitSignsChange = Utils.get_highlight("GitSignsChange")
        local GitSignsDelete = Utils.get_highlight("GitSignsDelete")
        local DiagnosticError = Utils.get_highlight("DiagnosticError")
        local DiagnosticWarn = Utils.get_highlight("DiagnosticWarn")
        local DiagnosticHint = Utils.get_highlight("DiagnosticHint")
        local DiagnosticInfo = Utils.get_highlight("DiagnosticInfo")

        local colors = {
          close_fg = Error.fg,
          fg = StatusLine.fg,
          bg = StatusLine.bg,
          section_fg = StatusLine.fg,
          section_bg = StatusLine.bg,
          git_branch_fg = Conditional.fg,
          mode_fg = StatusLine.bg,
          treesitter_fg = String.fg,
          virtual_env_fg = NvimEnvironmentName.fg,
          scrollbar = TypeDef.fg,
          git_added = GitSignsAdd.fg,
          git_changed = GitSignsChange.fg,
          git_removed = GitSignsDelete.fg,
          diag_ERROR = DiagnosticError.fg,
          diag_WARN = DiagnosticWarn.fg,
          diag_INFO = DiagnosticInfo.fg,
          diag_HINT = DiagnosticHint.fg,
          winbar_fg = WinBar.fg,
          winbar_bg = WinBar.bg,
          winbarnc_fg = WinBarNC.fg,
          winbarnc_bg = WinBarNC.bg,
          tabline_bg = TabLineFill.bg,
          tabline_fg = TabLineFill.bg,
          buffer_fg = Comment.fg,
          buffer_path_fg = WinBarNC.fg,
          buffer_close_fg = Comment.fg,
          buffer_bg = TabLineFill.bg,
          buffer_active_fg = Normal.fg,
          buffer_active_path_fg = WinBarNC.fg,
          buffer_active_close_fg = Error.fg,
          buffer_active_bg = Normal.bg,
          buffer_visible_fg = Normal.fg,
          buffer_visible_path_fg = WinBarNC.fg,
          buffer_visible_close_fg = Error.fg,
          buffer_visible_bg = Normal.bg,
          buffer_overflow_fg = Comment.fg,
          buffer_overflow_bg = TabLineFill.bg,
          buffer_picker_fg = Error.fg,
          tab_close_fg = Error.fg,
          tab_close_bg = TabLineFill.bg,
          tab_fg = TabLine.fg,
          tab_bg = TabLine.bg,
          tab_active_fg = TabLineSel.fg,
          tab_active_bg = TabLineSel.bg,
          -- inactive = HeirlineInactive,
          -- normal = HeirlineNormal,
          -- insert = HeirlineInsert,
          -- visual = HeirlineVisual,
          -- replace = HeirlineReplace,
          -- command = HeirlineCommand,
          -- terminal = HeirlineTerminal,
        }

        for _, section in ipairs({
          "git_branch",
          "file_info",
          "git_diff",
          "diagnostics",
          "lsp",
          "macro_recording",
          "mode",
          "cmd_info",
          "treesitter",
          "nav",
          "virtual_env",
        }) do
          if not colors[section .. "_bg"] then
            colors[section .. "_bg"] = colors["section_bg"]
          end
          if not colors[section .. "_fg"] then
            colors[section .. "_fg"] = colors["section_fg"]
          end
        end

        return colors
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
