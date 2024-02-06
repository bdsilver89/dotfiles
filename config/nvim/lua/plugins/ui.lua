return {
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  {
    "rcarriga/nvim-notify",
    enabled = false,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.component_separators = "|"
      opts.options.section_separators = ""
      return opts
    end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = "LazyFile",
    -- TODO: Attach and detach
    -- require("colorizer").attach_to_buffer(0, { mode = "background", css = true})
    -- require("colorizer").detach_from_buffer(0, { mode = "virtualtext", css = true})
    config = true,
  },
  -- {
  --   "b0o/incline.nvim",
  --   event = "BufReadPre",
  --   priority = 1200,
  --   config = {
  --     window = { margin = { vertical = 0, horizontal = 1 } },
  --     hide = { cursorline = true },
  --     render = function(props)
  --       local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
  --       local filename = (bufname and bufname ~= "") and bufname or "[No Name]"
  --       if vim.bo[props.buf].modified then
  --         filename = "● " .. filename
  --       end
  --
  --       local icon, color = require("nvim-web-devicons").get_icon_color(bufname)
  --
  --       return {
  --         { icon, guifg = color },
  --         { " " },
  --         { filename },
  --       }
  --     end,
  --   },
  -- },
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      opts.commands = {
        all = {
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })

      opts.presets.lsp_doc_border = true
    end,
  },
}
