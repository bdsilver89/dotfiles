local add = require("pack").add

add({
  {
    src = "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { name = "clangd", timeout_ms = 500, lsp_format = "prefer" },
        cpp = { name = "clangd", timeout_ms = 500, lsp_format = "prefer" },
        java = { "palantir-java-format" },
        javascript = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        javascriptreact = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        json = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        jsonc = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        less = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        python = { "ruff_format" },
        rust = { name = "rust_analyzer", timeout_ms = 500, lsp_format = "prefer" },
        scss = { "prettier" },
        sh = { "shfmt" },
        typescript = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        typescriptreact = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        yaml = { "prettier" },
        ["_"] = { "trim_whitespace", "trim_newlines" },
      },
      format_on_save = function()
        if not vim.g.autoformat then
          return nil
        end

        return {}
      end,
    },
    on_setup = function()
      vim.keymap.set("n", "<leader>uf", function()
        vim.g.autoformat = not vim.g.autoformat
        vim.notify(string.format("%s formatting", vim.g.autoformat and "Enabling" or "Disabling"))
      end, { desc = "Toggle autoformat" })
      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        require("conform").format({ lsp_format = "fallback" })
      end, { desc = "Format buffer" })
    end,
  },
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.g.autoformat = true
