local lsp_path = vim.fn.stdpath("config") .. "/lsp"
if vim.fn.isdirectory(lsp_path) == 1 then
  for name, type in vim.fs.dir(lsp_path) do
    if type == "file" and name:match("%.lua$") then
      local lsp_name = name:gsub("%.lua$", "")
      vim.lsp.enable(lsp_name)
    end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lspattach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration)

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
