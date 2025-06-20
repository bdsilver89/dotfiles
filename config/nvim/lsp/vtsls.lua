return {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  settings = {},
  on_attach = function()
    vim.keymap.set("n", "<leader>co", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.organizeImports" },
          diagnostics = {},
        },
      })
    end, { desc = "Organize Imports (JS/TS)" })

    vim.keymap.set("n", "<leader>cM", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.addMissingImports.ts" },
          diagnostics = {},
        },
      })
    end, { desc = "Add Missing Imports (JS/TS)" })

    vim.keymap.set("n", "<leader>cu", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.removeUnused.ts" },
          diagnostics = {},
        },
      })
    end, { desc = "Remove Unused Imports (JS/TS)" })

    vim.keymap.set("n", "<leader>cD", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "sourec.fixAll.ts" },
          diagnostics = {},
        },
      })
    end, { desc = "Fix All Diagnostics (JS/TS)" })

    -- vim.keymap.set("n", "<leader>cV", function()
    --   vim.lsp.buf_request(0, "workspace/exeuteCommand", {
    --     command = "typescript.selectTypeScriptVersion",
    --   })
    -- end, { desc = "Select TS Workspace Version (JS/TS)" })
  end,
}
