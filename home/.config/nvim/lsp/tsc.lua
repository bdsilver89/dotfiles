---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local root = config.root_dir or vim.fn.getcwd()
    local local_tsc = vim.fs.joinpath(root, "node_modules", ".bin", "tsc")
    local executable = vim.fn.executable(local_tsc) == 1 and local_tsc or "tsc"

    return vim.lsp.rpc.start({ executable, "--lsp", "--stdio" }, dispatchers, {
      cwd = config.cmd_cwd or root,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
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
