local icons = require("icons")

vim.diagnostic.config({
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  status = {
    format = function(counts)
      local items = {}
      for severity, count in pairs(counts) do
        local name = vim.diagnostic.severity[severity]
        local hl = "DiagnosticSign" .. name:sub(1, 1) .. name:sub(2):lower()
        table.insert(items, ('%%#%s#%s %d'):format(hl, icons.diagnostics[name], count))
      end
      return table.concat(items, " ")
    end,
  },
  virtual_text = {
    spacing = 2,
  },
  float = {
    source = "if_many",
    prefix = function(diag)
      local level = vim.diagnostic.severity[diag.severity]
      local prefix = string.format(" %s ", icons.diagnostics[level])
      return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.ERROR,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.WARN,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.HINT,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.INFO,
    },
  }
})

-- Give every server blink's completion capabilities (blink does not register
-- these itself). Servers started via vim.lsp.enable inherit the "*" config.
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.enable({
  "lua_ls",
  "clangd",
  "rust_analyzer",
})

local function on_attach(client, bufnr)
  -- local function keymap(lhs, rhs, opts, mode)
  --   mode = mode or "n"
  --   opts = type(opts) == "string" and { desc = opts } or opts
  --   opts.buffer = bufnr
  --   vim.keymap.set(mode, lhs, rhs, opts)
  -- end

  if client:supports_method("textDocument/completion") then
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
  end

  if client:supports_method("textDocument/documentColor") then
    vim.lsp.document_color.enable(true, { bufnr = bufnr }, {
      style = "virtual",
    })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    on_attach(client, ev.buf)
  end,
})

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "java",
--   callback = function()
--     local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
--     local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name
--     vim.fn.mkdir(workspace_dir, "p")
--
--     local opts = {
--       cmd = {
--         "java",
--         "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--         "-Dosgi.bundles.defaultStartLevel=4",
--         "-Declipse.product=org.eclipse.jdt.ls.core.product",
--         "-Dlog.protocol=true",
--         "-Dlog.level=ALL",
--         "-javaagent:" .. vim.fn.expand("$MASON/share/jdtls/lombok.jar"),
--         "-Xms1g",
--         "--add-modules=ALL-SYSTEM",
--         "--add-opens",
--         "java.base/java.util=ALL-UNNAMED",
--         "--add-opens",
--         "java.base/java.lang=ALL-UNNAMED",
--         "-jar",
--         vim.fn.expand("$MASON/share/jdtls/plugins/org.eclipse.equinox.launcher.jar"),
--         "-configuration",
--         vim.fn.expand("$MASON/share/jdtls/config"),
--         "-data",
--         workspace_dir,
--       },
--       root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }),
--       settings = {
--         java = {
--           eclipse = { downloadSources = true },
--           configuration = { updateBuildConfiguration = "interactive" },
--           maven = { downloadSources = true },
--           implementationsCodeLens = { enabled = true },
--           referencesCodeLens = { enabled = true },
--           inlayHints = { parameterNames = { enabled = "all" } },
--           signatureHelp = { enabled = true },
--           completion = {
--             favoriteStaticMembers = {
--               "org.hamcrest.MatcherAssert.assertThat",
--               "org.hamcrest.Matchers.*",
--               "org.hamcrest.CoreMatchers.*",
--               "org.junit.jupiter.api.Assertions.*",
--               "java.util.Objects.requireNonNull",
--               "java.util.Objects.requireNonNullElse",
--               "org.mockito.Mockito.*",
--             },
--           },
--           sources = {
--             organizeImports = {
--               starThreshold = 9999,
--               staticStarThreshold = 9999,
--             },
--           },
--         },
--       },
--       init_options = {
--         bundles = {
--           vim.fn.expand("$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar"),
--           -- unpack remaining bundles
--           (table.unpack or unpack)(vim.split(vim.fn.glob("$MASON/share/java-test/*.jar"), "\n", {})),
--         },
--       },
--       handlers = {
--         ["$/progress"] = function() end, -- disable progress updates.
--       },
--       filetypes = { "java" },
--       on_attach = function(client, bufnr)
--         require("jdtls").setup_dap({ hotcodereplace = "auto" })
--         local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
--         if astrolsp_avail then
--           astrolsp.on_attach(client, bufnr)
--         end
--       end,
--     }
--
--     if opts.root_dir and opts.root_dir ~= "" then
--       require("jdtls").start_or_attach(opts)
--     else
--       vim.notify("jdtls: root_dir not found", vim.log.levels.WARN)
--     end
--   end,
-- })
