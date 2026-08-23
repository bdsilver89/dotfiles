---@type vim.lsp.Config
return {
  cmd = { "tsgo", "--lsp", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    local root_markers = { { "package-lock.json", "yarn.lock", "pnpm-lock.yaml" }, { ".git" } }

    local project_root = vim.fs.root(bufnr, root_markers) or vim.uv.cwd()

    on_dir(project_root)
  end
}
