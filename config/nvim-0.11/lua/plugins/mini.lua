return {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
  -- stylua: ignore
  keys = {
    -- surround
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

    return {
      ai = {
        n_lines = 500,
        custom_textobjects = {
          o = require("mini.ai").gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inener" }),
        },
      },
      extra = {},
      hipatterns = {
        highlighters = {
          fixme = { pattern = "FIXME", group = "MiniHipatternsFixme" },
          hack = { pattern = "HACK", group = "MiniHipatternsHack" },
          todo = { pattern = "TODO", group = "MiniHipatternsTodo" },
          note = { pattern = "NOTE", group = "MiniHipatternsNote" },
        },
      },
      icons = {
        style = vim.g.has_nerd_font and "glyph" or "ascii",
      },
      statusline = {
        use_icons = vim.g.has_nerd_font,
      },
      tabline = {
        use_icons = vim.g.has_nerd_font,
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
          add = "gsa", -- Add surrounding in Normal and Visual modes
          delete = "gsd", -- Delete surrounding
          find = "gsf", -- Find surrounding (to the right)
          find_left = "gsF", -- Find surrounding (to the left)
          highlight = "gsh", -- Highlight surrounding
          replace = "gsr", -- Replace surrounding
          update_n_lines = "gsn", -- Update `n_lines`
        },
      },
    }
  end,
  config = function(_, opts)
    for k, v in pairs(opts) do
      require("mini." .. k).setup(v)
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

    require("config.utils").on_load("which-key.nvim", function()
      vim.schedule(function()
        local objects = {
          { "c", desc = "class" },
          { "f", desc = "function" },
        }

        local ret = { mode = { "o", "x" } }
        local mappings = vim.tbl_extend("force", {}, {
          around = "a",
          inside = "i",
          around_next = "an",
          inside_next = "in",
          around_last = "al",
          inside_last = "il",
        }, opts.mappings or {})
        mappings.goto_left = nil
        mappings.goto_right = nil

        for name, prefix in pairs(mappings) do
          name = name:gsub("^around_", ""):gsub("^inside_", "")
          ret[#ret + 1] = { prefix, group = name }
          for _, obj in ipairs(objects) do
            local desc = obj.desc
            if prefix:sub(1, 1) == "i" then
              desc = desc:gsub(" with ws", "")
            end
            ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
          end
        end
        require("which-key").add(ret, { notify = false })
      end)
    end)
  end,
}
