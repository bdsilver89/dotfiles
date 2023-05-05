return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "c")
      table.insert(opts.ensure_installed, "cpp")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {}
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "cmakelint")
      table.insert(opts.ensure_installed, "cmake-language-server")
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      table.insert(opts.sources, nls.builtins.formatting.clang_format)
      table.insert(opts.sources, nls.builtins.formatting.cmake_format)
      if vim.fn.executable("cppcheck") == 1 then
        table.insert(opts.sources, nls.builtins.diagnostics.cppcheck)
      end
      -- nls.builtins.diagnostics.cpplint })
    end,
  },
}
