return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          filetypes_exclude = { "markdown" },
          filetypes_includes = {},
        },
      },
      setup = {
        tailwindcss = function(_, opts)
          local tw = require("lspconfig.configs.tailwindcss")
          opts.filetypes = opts.filetypes or {}

          vim.list_extend(opts.filetypes, tw.default_config.filetypes)

          opts.filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
          end, opts.filetypes)

          vim.list_extend(opts.filetypes, opts.filetypes_include or {})
        end,
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        local format_item = format_kinds(entry, item)

        local entry_item = entry:get_completion_item()
        local color = entry_item.documentation

        if color and type(color) == "string" and color:match("^#%x%x%x%x%x%x$") then
          local hl = "hex-" .. color:sub(2)

          if #vim.api.nvim_get_hl(0, { name = hl }) == 0 then
            vim.api.nvim_set_hl(0, hl, { fg = color })
          end

          item.kind = "󱓻"
          item.kind_hl_group = hl
          item.menu_hl_group = hl
          return item
        end

        return format_item
      end
    end,
  },
}
