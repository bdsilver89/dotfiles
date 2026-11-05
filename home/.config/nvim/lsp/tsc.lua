---@type vim.lsp.Config
return {
  cmd = { "tsc", "--lsp", "-stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      {
        "package-lock.json",
        "yarn.json",
        "pnpm-lock.json",
      },
      {
        ".git",
      },
    }

    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

    on_dir(project_root)
  end,
}
