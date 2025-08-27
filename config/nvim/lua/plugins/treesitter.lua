return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = "VeryLazy",
  lazy = vim.fn.argc(-1) == 0,
  build = ":TSUpdate",
  opts = {},
  config = function(_, opts)
    local ensure_installed = {
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

    local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 end
    local to_install = vim.tbl_filter(isnt_installed, ensure_installed)
    if #to_install > 0 then
      ts.install(to_install)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = ensure_installed,
      callback = function(ev)
        vim.treesitter.start(ev.buf)
        vim.wo.foldlevel = 99
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
      end,
    })
  end,
}
