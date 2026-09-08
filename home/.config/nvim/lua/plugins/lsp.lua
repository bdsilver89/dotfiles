vim.diagnostic.config({
  severity_sort = true,
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ "bashls", "basedpyright", "clangd", "lua_ls", "ruff", "rust_analyzer", "jdtls", "tsc" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local function map(lhs, rhs, opts, mode)
      mode = mode or "n"
      opts = type(opts) == "string" and { desc = opts } or opts
      opts.buffer = ev.buf
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("gd", vim.lsp.buf.definition, "vim.lsp.buf.definition()")
    map("gD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration()")
    map("gW", vim.lsp.buf.workspace_symbol, "vim.lsp.buf.workspace_symbol()")
    map("grf", vim.diagnostic.open_float, "vim.diagnostic.open_float()")

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf)
    end
  end,
})
