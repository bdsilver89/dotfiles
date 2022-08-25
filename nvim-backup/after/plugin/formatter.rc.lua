local ok, formatter = pcall(require, 'formatter')
if (not ok) then return end

formatter.setup({
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    cmake = {
      require("formatter.filetypes.cmake").cmakeformat
    },
    cpp = {
      require("formatter.filetypes.cpp").clangformat
    },
    c = {
      require("formatter.filetypes.c").clangformat
    },
    go = {
      require("formatter.filetypes.go").gofmt
    },
    markdown = {
      require("formatter.filetypes.markdown").prettier
    },
    python = {
      require("formatter.filetypes.python").autopep8
    },
    rust = {
      require("formatter.filetypes.rust").rustfmt
    },
    sh = {
      require("formatter.filetypes.sh").shfmt
    },
    typescript = {
      require("formatter.filetypes.typescript").eslint_d
    },
    ["*"] = {
      require("formatter.filetypes.any").remove_trailing_whitespace
    }
  }
})

vim.keymap.set('n', '<leader>f', '<cmd>Format<CR>', { silent = true })
vim.keymap.set('n', '<leader>F', '<cmd>FormatWrite<CR>', { silent = true })
