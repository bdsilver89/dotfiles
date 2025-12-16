local lsp_configs = {}
for _, c in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  lsp_configs[#lsp_configs + 1] = vim.fn.fnamemodify(c, ":t:r")
end
vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
vim.lsp.enable(lsp_configs)

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = true,
})


vim.api.nvim_create_user_command("LspStart", function(args)
  local server = args.fargs[1]
  if server then
    vim.lsp.enable(server)
  else
    vim.lsp.enable(lsp_configs)
  end
end, {
  nargs = "?",
  complete = function()
    return lsp_configs
  end,
})

vim.api.nvim_create_user_command("LspStop", function(args)
  local server = args.fargs[1]
  local clients = vim.lsp.get_clients({ name = server })
  if #clients == 0 then
    clients = vim.lsp.get_clients()
  end
  for _, client in ipairs(clients) do
    client:stop()
  end
end, {
  nargs = "?",
  complete = function()
    return vim.tbl_map(function(c)
      return c.name
    end, vim.lsp.get_clients())
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config/lsp", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    vim.bo[buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = buf, desc = desc })
    end


    map("n", "gd", vim.lsp.buf.definition, "vim.lsp.buf.definition")
    map("n", "gD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration")
    map("n", "grt", vim.lsp.buf.type_definition, "vim.lsp.buf.type_definition")
    map("n", "grs", vim.lsp.buf.signature_help, "vim.lsp.buf.signature_help")
    map({ "n", "x" }, "grf", vim.lsp.buf.format, "vim.lsp.buf.format")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "vim.lsp.buf.code_action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "vim.lsp.buf.rename")
    map("n", "<leader>cd", vim.diagnostic.open_float, "vim.diagnostic.open_float")
    map("n", "<leader>cq", vim.diagnostic.setqflist, "vim.diagnostic.setqflist")
    map("n", "<leader>cl", vim.diagnostic.setloclist, "vim.diagnostic.setloclist")

    if client:supports_method("textDocument/documentHighlight") then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
