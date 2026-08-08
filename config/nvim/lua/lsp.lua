-- Server configs live in lsp/<name>.lua, picked up off the runtimepath.
-- Binaries are installed per-machine; a missing one just means no LSP.

-- Built-in 'autocomplete' rather than blink.cmp, which needs a compiled fuzzy
-- matcher that vim.pack has no build step for. 'complete' is priority-ordered,
-- so LSP ("o") outranks the buffer sources.
vim.o.autocomplete = true
vim.o.complete = "o,.^5,w^5,b^5,u^5"
vim.o.completeopt = "menuone,popup,fuzzy,noselect"
vim.o.autocompletedelay = 60

vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

vim.lsp.enable({
  "clangd",
  "basedpyright",
  "ruff",
  "vtsls",
  "lua_ls",
  "bashls",
  "jsonls",
  "yamlls",
  "taplo",
  "rust_analyzer",
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local fzf = require("fzf-lua")

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
    end

    map("n", "gd", fzf.lsp_definitions, "Definition")
    map("n", "gr", fzf.lsp_references, "References")
    map("n", "gI", fzf.lsp_implementations, "Implementation")
    map("n", "gy", fzf.lsp_typedefs, "Type definition")
    map("n", "<leader>ss", fzf.lsp_document_symbols, "Document symbols")
    map("n", "<leader>sS", fzf.lsp_live_workspace_symbols, "Workspace symbols")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "K", vim.lsp.buf.hover, "Hover")

    if not client then
      return
    end

    -- No autotrigger: 'autocomplete' already drives the popup, and both race.
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, buf)
    end

    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      map("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
      end, "Toggle inlay hints")
    end

    if client:supports_method("textDocument/documentHighlight") then
      local group = vim.api.nvim_create_augroup("config_lsphighlight_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        buffer = buf,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = buf,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

vim.diagnostic.config({
  virtual_text = { current_line = true },
  severity_sort = true,
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.INFO] = "󰋽",
      [vim.diagnostic.severity.HINT] = "󰌶",
    },
  },
  float = { source = true },
})
