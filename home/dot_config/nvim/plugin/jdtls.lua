local add_on_filetype = require("pack").add_on_filetype

add_on_filetype("java", {
  {
    src = "mfussenegger/nvim-jdtls",
    module_name = "jdtls",
    setup = false,
    on_setup = function()
      local function start_jdtls()
        local cmd

        local mason_jdtls = vim.fn.exepath("jdtls")
        if mason_jdtls ~= "" then
          -- Installed via mason.nvim (or otherwise on PATH): the bundled
          -- launcher script locates its own jar/config, no homebrew needed.
          cmd = { mason_jdtls }
        else
          local homebrew_prefix = vim.env.HOMEBREW_PREFIX or "/opt/homebrew"
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx4g",
            "-XX:+UseG1GC",
            "-XX:+UseStringDeduplication",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "-jar",
            vim.fn.glob(homebrew_prefix .. "/opt/jdtls/libexec/plugins/org.eclipse.equinox.launcher_*.jar"),
            "-configuration",
            homebrew_prefix .. "/opt/jdtls/libexec/config_mac_arm",
          }
        end

        local root_dir = vim.fs.root(0, { "settings.gradle", "build.gradle", "gradlew", ".git" })
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
          settings = {
            java = {
              inlayHints = {
                parameterNames = { enabled = "all" },
              },
              import = {
                exclusions = {
                  "**/build/**",
                  "**/.gradle/**",
                  "**/node_modules/**",
                  "**/.metadata/**",
                  "**/bin/**",
                  "**/out/**",
                },
              },
            },
          },
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = start_jdtls,
      })

      if vim.bo.filetype == "java" then
        start_jdtls()
      end
    end,
  },
})
