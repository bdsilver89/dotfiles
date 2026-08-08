-- Monorepo warning: vtsls picks one tsconfig by root detection and often gets
-- it wrong in workspaces. Narrow root_markers per project if that bites.
return {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript", "javascriptreact", "typescript", "typescriptreact",
  },
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      inlayHints = {
        parameterNames = { enabled = "literals" },
        variableTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
      },
    },
    vtsls = { experimental = { completion = { enableServerSideFuzzyMatch = true } } },
  },
}
