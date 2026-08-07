return {
  parsers = { "cmake" },

  servers = {
    neocmake = {},
  },

  mason = { "neocmake", "gersemi" },

  formatters_by_ft = {
    cmake = { "gersemi" },
  },
}
