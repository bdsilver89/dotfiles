-- jdtls only. Bundle-based debugging and test running need nvim-jdtls, which
-- takes over client startup entirely and is not wired here.
return {
  parsers = { "java" },

  servers = {
    jdtls = {},
  },

  mason = { "jdtls" },
}
