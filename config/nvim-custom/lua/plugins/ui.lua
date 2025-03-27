return {
  -- icons
  {
    "echasnovski/mini.icons",
    opts = {
      style = vim.g.has_nerd_font and "glyph" or "ascii",
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- statusline
  {
    "echasnovski/mini.statusline",
    event = "VeryLazy",
    opts = {
      use_icons = vim.g.has_nerd_font,
    },
    config = function(_, opts)
      local stl = require("mini.statusline")
      stl.setup(opts)

      stl.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },

  -- bufferline
  {
    "echasnovski/mini.tabline",
    event = "VeryLazy",
    opts = {
      use_icons = vim.g.has_nerd_font,
    },
  },

  -- hipatterns
  {
    "echasnovski/mini.hipatterns",
    event = "VeryLazy",
    opts = {
      highlighters = {
        fixme = { pattern = "FIXME", group = "MiniHipatternsFixme" },
        hack = { pattern = "HACK", group = "MiniHipatternsHack" },
        todo = { pattern = "TODO", group = "MiniHipatternsTodo" },
        note = { pattern = "NOTE", group = "MiniHipatternsNote" },
      },
    },
  },

  -- {
  --   "snacks.nvim",
  --   opts = {
  --     indent = {
  --       enabled = true,
  --       animate = {
  --         enabled = false,
  --       },
  --     },
  --     scope = { enabled = true },
  --     words = { enabled = true },
  --   },
  -- },
}
