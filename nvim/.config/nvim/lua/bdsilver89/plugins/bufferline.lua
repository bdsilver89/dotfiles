return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        close_command = function(n)
          require("mini.bufremove").delete(n, false)
        end,
        right_mouse_command = function(n)
          require("mini.bufremove").delete(n, false)
        end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "slant" or "padded_slant",
        color_icons = true,
        diagnostics_indicator = function(_, _, diag)
          local icons = require("bdsilver89.config.icons").diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "dapui_scopes",
            text = "DAP",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "dapui_stacks",
            text = "DAP",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "dapui_breakpoints",
            text = "DAP",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "dapui_watches",
            text = "DAP",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },
  {
    "tiagovla/scope.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
