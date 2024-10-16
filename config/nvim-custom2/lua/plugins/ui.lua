return {
  -- icons
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.enable_icons and vim.g.enable_nvim_devicons,
    lazy = true,
  },
  {
    "echasnovski/mini.icons",
    enabled = vim.g.enable_icons and vim.g.enable_mini_icons,
    lazy = true,
    opts = {
      style = vim.g.enable_icons and "glyph" or "ascii",
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
