vim.pack.add({
  "https://github.com/mfussenegger/nvim-jdtls",
})

-- Extension bundles (java-debug-adapter, java-test, …) handed to jdtls. Empty
-- for now; this is the single source of truth — add jar paths here and both the
-- LSP init_options and the reloadBundles handler below pick them up.
local bundles = {}

-- On startup jdtls calls the client command _java.reloadBundles.command and
-- expects the client's current bundle list back (a List<String>). nvim-jdtls
-- ships no handler, so it replies MethodNotFound and jdtls logs the (benign)
-- error. Mirror what vscode-java does — return the actual bundle list — so the
-- answer stays correct once `bundles` is non-empty rather than hardcoding {}.
vim.lsp.commands["_java.reloadBundles.command"] = vim.lsp.commands["_java.reloadBundles.command"]
  or function()
    return bundles
  end

local function start_jdtls()
  local jdtls = require("jdtls")

  local root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
  if not root_dir then
    return
  end

  -- One workspace per project so jdtls keeps separate indexes.
  local mason = vim.fn.stdpath("data") .. "/mason"
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

  jdtls.start_or_attach({
    cmd = {
      mason .. "/bin/jdtls",
      "-data", workspace_dir,
      "--jvm-arg=-javaagent:" .. mason .. "/packages/jdtls/lombok.jar",
    },
    root_dir = root_dir,
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    init_options = {
      bundles = bundles,
    },
    settings = {
      java = {
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        configuration = { updateBuildConfiguration = "interactive" },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        signatureHelp = { enabled = true },
        inlayHints = { parameterNames = { enabled = "all" } },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      },
    },
  })
end

-- Loaded from init.lua before any buffer's filetype is detected, so the
-- FileType autocmd fires for the first Java buffer too.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = start_jdtls,
})
