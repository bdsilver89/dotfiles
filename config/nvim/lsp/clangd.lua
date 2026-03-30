local function jobs()
  local ok, result = pcall(function()
    local cpus = vim.uv.cpu_info()
    local count = #cpus
    if count < 1 then
      count = 1
    end
    return math.max(1, math.ceil(count / 2))
  end)
  if ok then
    return result
  else
    return 2
  end
end

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
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    ".git",
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
  settings = {
    clangd = {
      semanticHighlighting = true,
    },
  },
}
