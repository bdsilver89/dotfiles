local status, nvim_lsp = pcall(require, 'lspconfig')
if (not status) then return end

local Remap = require('bdsilver89.keymap')
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local function config(_config)
  return vim.tbl_deep_extend('force', {
    capabilities = require('cmp_nvim_lsp').update_capabilities(
      vim.lsp.protocol.make_client_capabilities()),
    on_attach = function()
      -- most of this is covered by lspsaga, but this is here for reference
      -- or for a less 'popup' based experience
      -- nnoremap('gd', function() vim.lsp.buf.definition() end)
      nnoremap('gd', function() vim.lsp.buf.declaration() end)
      nnoremap('gi', function() vim.lsp.buf.implementation() end)
      -- nnoremap('K', function() vim.lsp.buf.hover() end)
      -- nnoremap('<leader>vws', function() vim.lsp.buf.workspace_symbol() end)
      -- nnoremap('<leader>vd', function() vim.diagnostic.open_float() end)
      -- nnoremap('[d', function() vim.diagnostic.goto_next() end)
      -- nnoremap(']d', function() vim.diagnostic.goto_prev() end)
      -- nnoremap('<leader>vca', function() vim.lsp.buf.code_action() end)
      -- nnoremap('<leader>vco', function() vim.lsp.buf.code_action({
      --   filter = function(code_action)
      --     if not code_action or not code_action.data then
      --       return false
      --     end
      --
      --     local data = code_action.data.id
      --     return string.sub(data, #data - 1, #data) == ':0'
      --   end,
      --   apply = true
      -- }) end)
      -- nnoremap('<leader>vrr', function() vim.lsp.buf.references() end)
      -- nnoremap('<leader>vrn', function() vim.lsp.buf.rename() end)
      -- inoremap('<C-h>', function() vim.lsp.buf.signature_help() end)
    end,
  }, _config or {})
end

nvim_lsp.tsserver.setup(config())

nvim_lsp.solang.setup(config())

nvim_lsp.tailwindcss.setup(config())

nvim_lsp.pyright.setup(config())

nvim_lsp.dockerls.setup(config())

nvim_lsp.bashls.setup(config())

nvim_lsp.sqlls.setup(config())

nvim_lsp.jsonls.setup(config())

nvim_lsp.yamlls.setup(config())

nvim_lsp.cmake.setup(config())

nvim_lsp.clangd.setup(config({
  cmd = {
    'clangd',
    '--background-index',
    '--suggest-missing-includes',
    '--clang-tidy',
    '--header-insertion=iwyu',
  }
}))

nvim_lsp.gopls.setup(config({
  cmd = { 'gopls', 'serve' },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}))

nvim_lsp.rust_analyzer.setup(config({
  cmd = { 'rustup', 'run', 'nightly', 'rust-analyzer' },
}))

nvim_lsp.sumneko_lua.setup(config({
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false
      },
    },
  },
}))

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 4, prefix = "●" },
  severity_sort = true,
})

-- Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = {
    prefix = '●'
  },
  update_in_insert = true,
  float = {
    source = "always", -- Or "if_many"
  },
})

