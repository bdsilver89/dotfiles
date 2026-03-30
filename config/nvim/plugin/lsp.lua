local servers = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  servers[#servers + 1] = vim.fn.fnamemodify(path, ":t:r")
end
vim.lsp.enable(servers)

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  virtual_text = true,
  virtual_lines = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP setup",
  group = vim.api.nvim_create_augroup("config_lsp", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

    -- stylua: ignore start
    vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "Definition", buffer = ev.buf })
    vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "Declaration", buffer = ev.buf })
    vim.keymap.set("n", "grf", vim.lsp.buf.format, { desc = "Format", buffer = ev.buf })
    -- stylua: ignore end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local hl_group_name = "config_lsp_highlight"
      local hl_group = vim.api.nvim_create_augroup(hl_group_name, { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = ev.buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = ev.buf,
        group = hl_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("config_lsp_detach", { clear = true }),
        callback = function(ev2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = hl_group_name, buffer = ev2.buf })
        end,
      })
    end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      vim.keymap.set("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, { desc = "Toggle Inlay Hints" })
    end
  end,
})
