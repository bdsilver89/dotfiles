for _, file in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  local server_name = vim.fn.fnamemodify(file, ":t:r")
  vim.lsp.enable(server_name)
end

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  virtual_lines = {
    current_line = true,
  },
  virtual_text = {
    current_line = false,
  },
})

vim.keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  else
    return "<Tab>"
  end
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet.active({ direction = -1 }) then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  else
    return "<S-Tab>"
  end
end, { expr = true })

vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    if vim.fn.complete_info({ "selected" }).selected ~= -1 then
      return "<C-y>"
    end
    return "<C-e><CR>"
  end
  return "<CR>"
end, { expr = true })

local group = vim.api.nvim_create_augroup("config_lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client_id = ev.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    map("grd", vim.lsp.buf.definition, "vim.lsp.buf.definition()")
    map("grD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration()")
    map("grf", vim.lsp.buf.format, "vim.lsp.buf.format()")

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client_id, ev.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
    end
    if client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = ev.buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        buffer = ev.buf,
        group = hl_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        buffer = ev.buf,
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
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end
    if client:supports_method("textDocument/inlayHint") then
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, "Toggle Inlay Hints")
    end
  end,
})

vim.api.nvim_create_autocmd("LspProgress", {
  desc = "Echo LSP progress",
  callback = function(ev)
    local data = ev.data.params.value
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local name = client and client.name or ""
    local msg = name .. ": " .. (data.title or "") .. (data.message and " " .. data.message or "")
    local status = data.kind == "end" and "success" or "running"
    vim.api.nvim_echo({ { msg } }, false, {
      kind = "progress",
      source = name,
      id = "lsp_progress_" .. ev.data.client_id,
      status = status,
      percent = data.percentage,
    })
  end,
})
