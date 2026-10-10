return {
  cmd = function(dispatchers, config)
    -- Each project needs a separate Java workspace, including equal folder names.
    local root = config.root_dir or vim.fn.getcwd()
    local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.sha256(root)
    return vim.lsp.rpc.start({ "jdtls", "-data", workspace }, dispatchers)
  end,
  filetypes = { "java" },
  root_markers = {
    { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" },
    { "pom.xml", "build.gradle", "build.gradle.kts", ".git" },
  },
}
