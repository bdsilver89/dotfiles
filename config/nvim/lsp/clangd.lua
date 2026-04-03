local function switch_source_header(bufnr, client)
  local method_name = "textDocument/switchSourceHeader"
  if not client or not client:supports_method(method_name) then
    return
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify("corresponding file cannot be determined")
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function jobs()
  local half = math.floor(#vim.uv.cpu_info() / 2)
  return math.max(2, half - half % 2)
end

---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "-j=" .. jobs(),
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--cross-file-rename=true",
    "--pch-storage=disk",
    "--limit-references=500",
    "--limit-results=50",
    "--enable-config",
  },
  filetypes = { "c", "cpp" },
  root_markers = {
    ".clangd",
    ".clangd-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    ".git",
  },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-16" },
  },
  settings = {
    clangd = {
      semanticHighlighting = true,
    },
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspClangdSwitchSourceHeader", function()
      switch_source_header(bufnr, client)
    end, { desc = "Switch between source/header" })
  end,
}
