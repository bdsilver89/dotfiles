local Utils = require("bdsilver89.utils")

return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  dependencies = {
    "SmiteshP/nvim-navic",
  },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      disabled_filetypes = {
        statusline = {
          "dashboard",
          "alpha",
        },
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {
        {
          "diagnostics",
          symbols = {
            error = Utils.get_icon("DiagnosticError"),
            warn = Utils.get_icon("DiagnosticWarn"),
            info = Utils.get_icon("DiagnosticInfo"),
            hint = Utils.get_icon("DiagnosticHint"),
          },
        },
        {
          "filetype",
          icon_only = true,
          separator = "",
          padding = {
            left = 1,
            right = 0,
          },
        },
        {
          "filename",
          path = 1,
          symbols = {
            modified = "  ",
            readonly = "",
            unnamed = "",
          },
        },
        {
          function()
            return require("nvim-navic").get_location()
          end,
          cond = function()
            return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
          end,
        },
      },
      lualine_x = {
        {
          function()
            return require("noice").api.status.command.get()
          end,
          cond = function()
            return package.loaded["noice"] and require("noice").api.status.command.has()
          end,
        },
        {
          function()
            return require("noice").api.status.mode.get()
          end,
          cond = function()
            return package.loaded["noice"] and require("noice").api.status.mode.has()
          end,
        },
        {
          function()
            return "  " .. require("dap").status()
          end,
          cond = function()
            return package.loaded["dap"] and require("dap").status() ~= ""
          end,
          color = Utils.fg("Debug"),
        },
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = Utils.fg("Special"),
        },
        {
          "diff",
          symbols = {
            added = Utils.get_icon("GitAdd"),
            modified = Utils.get_icon("GitChange"),
            removed = Utils.get_icon("GitDelete"),
          },
        },
      },
      lualine_y = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      },
      lualine_z = {
        function()
          return " " .. os.date("%R")
        end,
      },
    },
    extensions = {
      "neo-tree",
      "lazy",
    },
  },
}
