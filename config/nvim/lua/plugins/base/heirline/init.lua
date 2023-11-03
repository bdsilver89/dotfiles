return {
  {
    "rebelot/heirline.nvim",
    event = "BufEnter",
    opts = function()
      return {
        statusline = require("plugins.base.heirline.statusline").setup(),
        statuscolumn = require("plugins.base.heirline.statuscolumn").setup(),
        winbar = require("plugins.base.heirline.winbar").setup(),
        tabline = require("plugins.base.heirline.tabline").setup(),
        opts = {
          disable_winbar_cb = function(args)
            return require("heirline.conditions").buffer_matches({
              buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
              filetype = {
                "NvimTree",
                "neo-tree",
                "Trouble",
                "dashboard",
                "aerial",
                "aerial-nav",
                "lspinfo",
                "toggleterm",
                "harpoon",
              },
            }, args.buf)
          end,
        },
      }
    end,
    config = function(_, opts)
      local heirline = require("heirline")
      local utils = require("heirline.utils")

      local function setup_colors()
        return {}
      end

      heirline.load_colors(setup_colors())
      heirline.setup(opts)

      vim.api.nvim_create_autocmd("colorscheme", {
        desc = "Update heirline color",
        group = vim.api.nvim_create_augroup("heirline_color", { clear = true }),
        callback = function()
          utils.on_colorscheme(setup_colors())
        end,
      })
    end,
  },
}
