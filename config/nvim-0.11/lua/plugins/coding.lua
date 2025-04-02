return {
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  {
    "echasnovski/mini.nvim",
    keys = function(_, keys)
      local opts = require("config.utils").opts("mini.nvim")
      local mappings = {
        { opts.surround.mappings.add, desc = "Add Surrounding", mode = { "n", "v" } },
        { opts.surround.mappings.delete, desc = "Delete Surrounding" },
        { opts.surround.mappings.find, desc = "Find Right Surrounding" },
        { opts.surround.mappings.find_left, desc = "Find Left Surrounding" },
        { opts.surround.mappings.highlight, desc = "Highlight Surrounding" },
        { opts.surround.mappings.replace, desc = "Replace Surrounding" },
        { opts.surround.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = function(_, opts)
      opts.pairs = {
        opts = {
          modes = { insert = true, command = true, terminal = false },
          -- skip autopair when next character is one of these
          skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
          -- skip autopair when the cursor is inside these treesitter nodes
          skip_ts = { "string" },
          -- skip autopair when next character is closing pair
          -- and there are more closing pairs than opening pairs
          skip_unbalanced = true,
          -- better deal with markdown code blocks
          markdown = true,
        },
      }

      opts.surround = {
        mappings = {
          add = "gsa", -- Add surrounding in Normal and Visual modes
          delete = "gsd", -- Delete surrounding
          find = "gsf", -- Find surrounding (to the right)
          find_left = "gsF", -- Find surrounding (to the left)
          highlight = "gsh", -- Highlight surrounding
          replace = "gsr", -- Replace surrounding
          update_n_lines = "gsn", -- Update `n_lines`
        },
      }

      local ai = require("mini.ai")
      opts.ai = {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inener" }),
        },
      }

      -- register text objects with which-key
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
  },
}
