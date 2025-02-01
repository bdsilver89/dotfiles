-- most of the settings are alreday covered by typescript language config
-- file so just need to add angular treesitter and lsp support

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "angular", "scss" })
      end
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.component.html", "*.container.html" },
        callback = function()
          vim.treesitter.start(nil, "angular")
        end,
      })
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "angular-language-server",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        angularls = {},
      },
    },
  },
}
