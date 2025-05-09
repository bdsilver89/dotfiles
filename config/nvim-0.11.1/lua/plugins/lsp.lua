return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "mason.nvim",
    {
      "mason-org/mason-lspconfig.nvim",
      opts = {
        ensure_installed = require("lang").lsp(),
      },
    },
  },
  config = function()
    local icons = require("icons")

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP settings",
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
          return
        end

        local function map(lhs, rhs, opts, mode)
          mode = mode or "n"
          opts = type(opts) == "string" and { desc = opts } or type(opts) == "table" and opts or {}
          opts = vim.tbl_deep_extend("force", { buffer = event.buf }, opts)
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- keymaps
        -- map("grt", vim.lsp.buf.type_definition, "vim.lsp.buf.type_definition()")
        -- map("gri", vim.lsp.buf.implementation, "vim.lsp.buf.implementation()")
        -- map("grs", vim.lsp.buf.document_symbol, "vim.lsp.buf.document_symbol()")
        -- map("grw", vim.lsp.buf.workspace_symbol, "vim.lsp.buf.workspace_symbol()")
        -- if client:supports_method("textDocument/definition") then
        --   map("gd", vim.lsp.buf.definition, "vim.lsp.buf.defintion()")
        --   map("gD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration()")
        -- end


        -- stylua: ignore start
        map("<leader>cl", function() Snacks.picker.lsp_config() end, "LSP config")
        map("grt", function() Snacks.picker.lsp_type_definitions() end, "vim.lsp.buf.type_definition()")
        map("gri", function() Snacks.picker.lsp_implementations() end, "vim.lsp.buf.implementation()")
        map("grr", function() Snacks.picker.lsp_references() end, "vim.lsp.buf.references()")
        map("<leader>ss", function() Snacks.picker.lsp_symbols() end, "vim.lsp.buf.document_symbol()")
        map("<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, "vim.lsp.buf.workspace_symbol()")

        if client:supports_method("textDocument/definition") then
          map("gd", function() Snacks.picker.lsp_definitions() end, "vim.lsp.buf.definition()")
          map("gD", function() Snacks.picker.lsp_declarations() end, "vim.lsp.buf.definition()")
        end
        -- stylua: ignore end

        -- inlay hints
        if client:supports_method("textDocument/inlayHint") then
          local inlay_hints_group = vim.api.nvim_create_augroup("bdsilver89/toggle_inlay_hints", { clear = false })

          vim.defer_fn(function()
            local mode = vim.api.nvim_get_mode().mode
            vim.lsp.inlay_hint.enable(mode == "n" or mode == "v", { bufnr = event.buf })
          end, 500)

          vim.api.nvim_create_autocmd("InsertEnter", {
            group = inlay_hints_group,
            desc = "Enable inlay hints",
            buffer = event.buf,
            callback = function()
              if vim.g.inlay_hints then
                vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
              end
            end,
          })

          vim.api.nvim_create_autocmd("InsertLeave", {
            group = inlay_hints_group,
            desc = "Disable inlay hints",
            buffer = event.buf,
            callback = function()
              if vim.g.inlay_hints then
                vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
              end
            end,
          })
        end

        -- codelens
        if client:supports_method("textDocument/codeLens") then
          map("grc", vim.lsp.codelens.run, "vim.lsp.codelens.run()")
          map("grC", vim.lsp.codelens.refresh, "vim.lsp.codelens.refresh()")
        end

        vim.diagnostic.config({
          underline = true,
          update_in_insert = false,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = icons.diagnostics.ERROR,
              [vim.diagnostic.severity.WARN] = icons.diagnostics.WARN,
              [vim.diagnostic.severity.HINT] = icons.diagnostics.HINT,
              [vim.diagnostic.severity.INFO] = icons.diagnostics.INFO,
            },
          },
          virtual_text = {
            spacing = 4,
            source = "if_many",
          },
          float = {
            source = "if_many",
          },
          severity_sort = true,
        })
      end,
    })
  end,
}
