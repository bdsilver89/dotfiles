return {
  {
    "rebelot/heirline.nvim",
    event = "BufEnter",
    opts = function()
      return {
        opts = {
          colors = require("plugins.heirline.common").setup_colors,
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
      require("heirline").setup(opts)

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("config_heirline_colors", { clear = true }),
        callback = function()
          require("heirline.utils").on_colorscheme(require("plugins.heirline.common").setup_colors)
        end,
      })
    end,
  }
}
