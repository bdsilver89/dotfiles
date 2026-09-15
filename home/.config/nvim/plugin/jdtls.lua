vim.pack.add({
  "https://github.com/mfussenegger/nvim-jdtls",
}, { load = false })

local function start_jdtls()
  local jdtls = vim.fs.normalize(vim.fn.stdpath("data") .. "/../jdtls/current/bin/jdtls")
  local cmd = {
    jdtls,
  }

  local root_dir = vim.fs.root(0, { "settings.gradle", "build.gradle", "gradlew", "mvnw", "pom.xml", ".git" })
  local project_name = root_dir and vim.fs.basename(root_dir)
  if project_name then
    vim.list_extend(cmd, {
      "-data",
      vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace",
    })
  end

  require("jdtls").start_or_attach({
    cmd = cmd,
    root_dir = root_dir,
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    settings = {},
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("configjdtls", { clear = true }),
  pattern = "java",
  callback = function()
    vim.cmd.packadd("nvim-jdtls")
    start_jdtls()
  end,
})
