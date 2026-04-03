local servers = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
  :map(function(path)
    return vim.fn.fnamemodify(path, ":t:r")
  end)
  :totable()
vim.lsp.enable(servers)

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  virtual_text = true,
  virtual_lines = false,
})

vim.keymap.set("n", "gro", vim.diagnostic.open_float, { desc = "vim.diagnostic.open_float()" })


local group = vim.api.nvim_create_augroup("config_lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP setup",
  group = group,
  callback = function(ev)
    local buf = ev.buf
    local client_id = ev.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    local map = function(lhs, rhs, opts, mode)
      mode = mode or "n"
      opts = type(opts) == "string" and { desc = opts } or opts
      opts.buffer = buf
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("grd", vim.lsp.buf.definition, "vim.lsp.buf.definition()")
    map("grD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration()")
    map("grf", vim.lsp.buf.format, "vim.lsp.buf.format()")

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client_id, ev.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = buf })
    end
    if client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, { bufnr = buf })
      map("grc", vim.lsp.document_color.color_presentation, "vim.lsp.document_color.color_presentation()", { "n", "x" })
    end
    if client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        buffer = buf,
        group = hl_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        buffer = buf,
        group = hl_group,
        callback = function(detach_ev)
          if detach_ev.data.client_id == client_id then
            vim.lsp.buf.clear_references()
            vim.api.nvim_del_augroup_by_id(hl_group)
          end
        end,
      })
    end
    if client:supports_method("textDocument/codeLens") then
      vim.lsp.codelens.enable(true, { bufnr = buf })
    end
    if client:supports_method("textDocument/inlayHint") then
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(
          not vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
        )
      end, "Toggle Inlay Hints")
    end
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  desc = "Redraw statusline on LSP progress",
  callback = function()
    vim.cmd.redrawstatus()
  end,
})
