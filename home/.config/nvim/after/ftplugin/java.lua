vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4

local mason = vim.fn.stdpath("data") .. "/mason"
local root_dir = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" }) or vim.uv.cwd()
local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.sha256(root_dir)

local config = {
  name = "jdtls",
  cmd = { "jdtls", "-data", workspace },
  root_dir = root_dir,
  settings = {
    java = {},
  },
  init_options = {
    bundles = vim.fn.glob(mason .. "/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar", true, true),
  },
  on_attach = function()
    require("jdtls").setup_dap({ hotcodereplace = "auto" })
  end,
}
require("jdtls").start_or_attach(config)
