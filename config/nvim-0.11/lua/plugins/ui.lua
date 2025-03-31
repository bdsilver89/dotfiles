return {
  {
    "mini.nvim",
    opts = function(_, opts)
      opts.cursorword = {}

      opts.icons = {
        style = vim.g.has_nerd_font and "glyph" or "ascii",
      }

      opts.indentscope = {
        draw = {
          animation = require("mini.indentscope").gen_animation.none(),
        },
        options = { try_as_border = true },
        -- symbol = vim.g.has_nerd_font and "│" or "╎",
      }

      opts.hipatterns = {
        highlighters = {
          fixme = { pattern = "FIXME", group = "MiniHipatternsFixme" },
          hack = { pattern = "HACK", group = "MiniHipatternsHack" },
          todo = { pattern = "TODO", group = "MiniHipatternsTodo" },
          note = { pattern = "NOTE", group = "MiniHipatternsNote" },
        },
      }

      opts.starter = {
        evaluate_single = true,
      }

      opts.statusline = {
        use_icons = vim.g.has_nerd_font,
      }

      opts.tabline = {
        use_icons = vim.g.has_nerd_font,
      }
    end,
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end

      local stl = require("mini.statusline")
      stl.section_location = function()
        return "%2l:%-2v"
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lazy", "mason" },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
}
