vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4

local config = {
  name = "jdtls",
  cmd = { "jdtls" },
  root_dir = vim.fs.root(0, { "gradlew", "mvnw", ".git" }),
  settings = {
    java = {},
  },
  init_options = {
    bundles = {},
  },
}
require("jdtls").start_or_attach(config)
