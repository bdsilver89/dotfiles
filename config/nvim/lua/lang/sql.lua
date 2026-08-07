-- No LSP: sqls is effectively unmaintained and postgres_lsp is dialect-locked.
-- sqlfluff is omitted for the same reason -- it errors without a project
-- .sqlfluff naming a dialect.
return {
  parsers = { "sql" },

  mason = { "sql-formatter" },

  formatters_by_ft = {
    sql = { "sql_formatter" },
  },
}
