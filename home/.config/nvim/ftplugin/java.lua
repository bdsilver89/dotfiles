local root_dir = vim.fs.root(0, { "mvnw", ".git" }) or vim.fs.root(0, "pom.xml")
if not root_dir then return end

local data_home = vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. vim.fn.sha256(root_dir)

require("jdtls").start_or_attach({
  cmd = {
    data_home .. "/jdtls/current/bin/jdtls",
    "-data",
    workspace_dir,
  },
  root_dir = root_dir,
  settings = {
    java = {
      maven = { downloadSources = true },
    },
  },
})
