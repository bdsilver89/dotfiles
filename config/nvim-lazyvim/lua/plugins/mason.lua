return {
  -- disable mason if required
  {
    "williamboman/mason.nvim",
    enabled = vim.g.enable_mason_packages,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enabled = vim.g.enable_mason_packages,
  },
  {
    "williamboman/mason-nvim-dap.nvim",
    enabled = vim.g.enable_mason_packages,
  },
}
