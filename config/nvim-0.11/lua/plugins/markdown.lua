return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "norg", "rmd", "org" },
  opts = {
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },
    heading = {
      sign = true,
      icons = {},
    },
    checkbox = {
      enabled = false,
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    Snacks.toggle({
      name = "Render Markdown",
      get = function()
        return require("render-markdown.state").enabled
      end,
      set = function(state)
        local m = require("render-markdown")
        if state then
          m.enable()
        else
          m.disable()
        end
      end,
    }):map("<leader>um")
  end,
}
