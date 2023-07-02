return {
  {
    "akinsho/bufferline.nvim",
    enabled = false,
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
          local get_icon = require("bdsilver89.utils").get_icon
          local ret = (diag.error and get_icon("DiagnosticError") .. " " .. diag.error .. " " or "")
            .. (diag.warning and get_icon("DiagnosticWarn") .. " " .. diag.warning or "")
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
}
