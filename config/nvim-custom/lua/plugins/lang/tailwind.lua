vim.g.enable_lang_tailwind = vim.fn.executable("node") == 1

if not (vim.g.enable_lang_tailwind ~= false) then
  return {}
end

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "tailwindcss-language-server" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          filetypes_exclude = { "markdown" },
          filetypes_include = {},
        },
      },
      setup = {
        tailwindcss = function(_, opts)
          local cfg = require("lspconfig.configs." .. "tailwindcss")
          opts.filetypes = opts.filetypes or {}

          vim.list_extend(opts.filetypes, cfg.default_config.filetypes)

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
    optional = true,
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", opts = {} },
    },
    opts = function(_, opts)
      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        format_kinds(entry, item) -- add icons
        return require("tailwindcss-colorizer-cmp").formatter(entry, item)
      end
    end,
  },
}
