return {
  parsers = { "toml" },

  servers = {
    taplo = {},
  },

  mason = { "taplo" },

  formatters_by_ft = {
    toml = { "taplo" },
  },
}
