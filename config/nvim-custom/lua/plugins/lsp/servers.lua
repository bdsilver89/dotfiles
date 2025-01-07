local M = {}

--- build capabilities from nvim, completion engine, and injected values
function M.make_capabilities()
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  local has_blink, blink = pcall(require, "blink.cmp")
  local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    has_cmp and cmp_nvim_lsp.default_capabilities() or {},
    has_blink and blink.get_lsp_capabilities() or {},
    {
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      },
    }
  )

  return capabilities
end

function M.setup()
  local lspconfig = require("lspconfig")
  local capabilities = M.make_capabilities()

  -- bashls
  lspconfig.bashls.setup({
    capabilities = capabilities,
  })

  -- cmake
  lspconfig.neocmake.setup({
    capabilities = capabilities,
  })

  -- cpp
  lspconfig.clangd.setup({
    capabilities = capabilities,
  })

  -- json
  lspconfig.jsonls.setup({
    capabilities = capabilities,
    on_new_config = function(new_config)
      new_config.settings.json.schemas = new_config.settings.json.schemas or {}
      vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
    end,
    settings = {
      json = {
        format = {
          enable = true,
        },
        validate = { enable = true },
      },
    },
  })

  -- lua
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.fn.expand("$VIMRUNTIME/lua"),
            vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
            vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
            "${3rd}/luv/library",
          },
        },
        codeLens = {
          enable = true,
        },
        completion = {
          callSnippet = "Replace",
        },
        doc = {
          privateName = { "^_" },
        },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
      },
    },
  })

  -- python
  lspconfig.ruff.setup({
    capabilities = capabilities,
  })

  -- zig
  lspconfig.zls.setup({
    capabilities = capabilities,
  })
end

return M
