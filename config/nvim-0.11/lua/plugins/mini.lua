return {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
  -- stylua: ignore
  keys = {
    { "gsa", desc = "Add Surrounding", mode = { "n", "v" } },
    { "gsd", desc = "Delete Surrounding" },
    { "gsf", desc = "Find Right Surrounding" },
    { "gsF", desc = "Find Left Surrounding" },
    { "gsh", desc = "Highlight Surrounding" },
    { "gsr", desc = "Replace Surrounding" },
    { "gsn", desc = "Update `MiniSurround.config.n_lines`" },
  },
  init = function()
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
  opts = function()
    local ai = require("mini.ai")
    local hipatterns = require("mini.hipatterns")

    return {
      ai = {
        n_lines = 500,
        custom_textobjects = {
          -- o = require("mini.ai").gen_spec.treesitter({
          --   a = { "@block.outer", "@conditional.outer", "@loop.outer" },
          --   i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          -- }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          l = ai.gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
          k = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
          a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
          ["?"] = ai.gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
        },
      },
      hipatterns = {
        highlighters = {
          fixme = { pattern = "FIXME", group = "MiniHipatternsFixme" },
          hack = { pattern = "HACK", group = "MiniHipatternsHack" },
          todo = { pattern = "TODO", group = "MiniHipatternsTodo" },
          note = { pattern = "NOTE", group = "MiniHipatternsNote" },
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      },

      icons = {},

      indentscope = {
        draw = {
          animation = require("mini.indentscope").gen_animation.none(),
        },
      },

      pairs = {
        opts = {
          modes = { insert = true, command = true, terminal = false },
          skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
          skip_ts = { "string" },
          skip_unbalanced = true,
          markdown = true,
        },
      },
      surround = {
        mappings = {
          add = "gsa",
          delete = "gsd",
          find = "gsf",
          find_left = "gsF",
          highlight = "gsh",
          replace = "gsr",
          update_n_lines = "gsn",
        },
      },
    }
  end,
  config = function(_, opts)
    for k, v in pairs(opts) do
      if v.setup ~= false then
        require("mini." .. k).setup(v)
      end
    end
  end,
}
