return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "zig" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        zls = {},
      },
    },
  },
  -- {
  --   "nvim-neotest/neotest",
  --   dependencies = {
  --   },
  --   opts = {
  --     adapters = {
  --     },
  --   },
  -- },
  -- {
  --   "mfussenegger/nvim-dap",
  --   dependencies = {
  --   },
  -- },
  {
    "ziglang/zig.vim",
    ft = { "zig" },
  },
}
