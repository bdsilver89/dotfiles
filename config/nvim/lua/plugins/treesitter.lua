return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = "VeryLazy",
  build = ":TSUpdate",
  opts = {},
  config = function(_, opts)
    local filetypes = {
      "bash",
      "c",
      "cmake",
      "cpp",
      "diff",
      "html",
      "java",
      "javascript",
      "lua",
      "luadoc",
      "luap",
      "make",
      "markdown",
      "markdown_inline",
      "ninja",
      "python",
      "printf",
      "query",
      "regex",
      "rust",
      "sql",
      "toml",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    }

    local ts = require("nvim-treesitter")
    ts.setup(opts)
    ts.install(filetypes)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function()
        vim.treesitter.start()
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
      end,
    })
  end,
}
