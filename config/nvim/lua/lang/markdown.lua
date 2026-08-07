return {
  parsers = { "markdown", "markdown_inline" },

  servers = {
    marksman = {},
  },

  mason = { "marksman", "markdownlint-cli2", "prettierd" },

  formatters_by_ft = {
    markdown = { "prettierd", "prettier", stop_after_first = true },
  },

  linters_by_ft = {
    markdown = { "markdownlint-cli2" },
  },
}
