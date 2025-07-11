return {
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    enabled = false,
    keys = {
      {
        "<leader>ue",
        function()
          require("edgy").toggle()
        end,
        desc = "Edgy Toggle",
      },
    },
    opts = function()
      local opts = {
        bottom = {
          {
            ft = "noice",
            size = { height = 0.4 },
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          "Trouble",
          { ft = "qf", title = "QuickFix" },
          {
            ft = "help",
            size = { height = 20 },
            -- don't open help files in edgy that we're editing
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },
          { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
        },
        left = {
          { title = "Neotest Summary", ft = "neotest-summary" },
          -- { title = "Snacks Explorer", ft = "snacks_picker_list",  },
        },
        right = {
          { title = "Grug Far", ft = "grug-far", size = { width = 0.4 } },
          { title = "Code Companion", ft = "codecompanion", size = { width = 50 } },
          {
            title = "Overseer",
            ft = "OverseerList",
            open = function()
              require("overseer").open()
            end,
          },
        },
        keys = {
          -- increase width
          ["<c-Right>"] = function(win)
            win:resize("width", 2)
          end,
          -- decrease width
          ["<c-Left>"] = function(win)
            win:resize("width", -2)
          end,
          -- increase height
          ["<c-Up>"] = function(win)
            win:resize("height", 2)
          end,
          -- decrease height
          ["<c-Down>"] = function(win)
            win:resize("height", -2)
          end,
        },
      }

      -- neo-tree
      local pos = {
        filesystem = "left",
        buffers = "top",
        git_status = "right",
        document_symbols = "bottom",
        diagnostics = "bottom",
      }
      local sources = {}
      local plugin = require("lazy.core.config").spec.plugins["neo-tree"]
      if plugin then
        sources = require("lazy.core.plugin").values(plugin, "opts", false).sources or {}
      end
      for i, v in ipairs(sources) do
        table.insert(opts.left, i, {
          title = "Neo-Tree " .. v:gsub("_", " "):gsub("^%l", string.upper),
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == v
          end,
          pinned = true,
          open = function()
            vim.cmd(("Neotree show position=%s %s"):format(pos[v] or "bottom", v))
          end,
        })
      end

      -- trouble
      for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "trouble",
          filter = function(_buf, win)
            return vim.w[win].trouble
              and vim.w[win].trouble.position == pos
              and vim.w[win].trouble.type == "split"
              and vim.w[win].trouble.relative == "editor"
              and not vim.w[win].trouble_preview
          end,
        })
      end

      -- snacks terminal
      for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "snacks_terminal",
          size = { height = 0.4 },
          title = "%{b:snacks_terminal.id}: %{b:term_title}",
          filter = function(_buf, win)
            return vim.w[win].snacks_win
              and vim.w[win].snacks_win.position == pos
              and vim.w[win].snacks_win.relative == "editor"
              and not vim.w[win].trouble_preview
          end,
        })
      end
      return opts
    end,
  },

  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function()
      local Offset = require("bufferline.offset")
      if not Offset.edgy then
        local get = Offset.get
        Offset.get = function()
          if package.loaded.edgy then
            local old_offset = get()
            local layout = require("edgy.config").layout
            local ret = { left = "", left_size = 0, right = "", right_size = 0 }
            for _, pos in ipairs({ "left", "right" }) do
              local sb = layout[pos]
              local title = " Sidebar" .. string.rep(" ", sb.bounds.width - 8)
              if sb and #sb.wins > 0 then
                ret[pos] = old_offset[pos .. "_size"] > 0 and old_offset[pos]
                  or pos == "left" and ("%#Bold#" .. title .. "%*" .. "%#BufferLineOffsetSeparator#│%*")
                  or pos == "right" and ("%#BufferLineOffsetSeparator#│%*" .. "%#Bold#" .. title .. "%*")
                ret[pos .. "_size"] = old_offset[pos .. "_size"] > 0 and old_offset[pos .. "_size"] or sb.bounds.width
              end
            end
            ret.total_size = ret.left_size + ret.right_size
            if ret.total_size > 0 then
              return ret
            end
          end
          return get()
        end
        Offset.edgy = true
      end
    end,
  },
}
