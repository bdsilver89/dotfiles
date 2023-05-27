return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        close_command = function(n)
          require("mini.bufremove").delete(n, false)
        end,
        right_mouse_command = function(n)
          require("mini.bufremove").delete(n, false)
        end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "slant" or "padded_slant",
        -- show_tab_indicators = true,
        -- show_close_icon = false,
        color_icons = true,
        -- enfore_regular_tabs = false,
        -- custom_filter = function(bufnr, _)
        --   local tab_num = 0
        --   for _ in pairs(vim.api.nvim_list_tabpages()) do
        --     tab_num = tab_num + 1
        --   end
        --
        --   if tab_num > 1 then
        --     if not not vim.api.nvim_buf_get_name(bufnr):find(vim.fn.getcwd(), 0, true) then
        --       return true
        --     end
        --   else
        --     return true
        --   end
        -- end,
        -- sort_by = function(buf_a, buf_b)
        --   local mod_a = ((vim.loop.fs_stat(buf_a.path) or {}).mtime or {}).sec or 0
        --   local mod_b = ((vim.loop.fs_stat(buf_b.path) or {}).mtime or {}).sec or 0
        --   return mod_a > mod_b
        -- end,
        diagnostics_indicator = function(_, _, diag)
          local icons = require("bdsilver89.config.icons").diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },
  {
    "tiagovla/scope.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
