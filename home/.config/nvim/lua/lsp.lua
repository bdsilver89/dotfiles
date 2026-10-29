vim.diagnostic.config({
  update_in_insert = false,
  virtual_text = true,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
})

vim.lsp.enable({
  "clangd",
  "lua_ls",
  "rust_analyzer",
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf })
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, { buffer = ev.buf })
    vim.keymap.set("n", "grf", vim.lsp.buf.format, { buffer = ev.buf })

    if client:supports_method("textDocument/inlayHint") then
      vim.keymap.set("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { buffer = ev.buf })
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})
