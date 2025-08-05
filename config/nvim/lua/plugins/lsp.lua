return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
          return
        end

        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
        end

        -- extra keymaps to pair with the defaults
        map("grd", vim.lsp.buf.definition, "vim.lsp.buf.definition")
        map("grD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration")
        map("gW", vim.lsp.buf.workspace_symbol, "vim.lsp.buf.workspace_symbol")
      end,
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            checkThirdParty = false,
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
              [vim.fn.stdpath("data") .. "/lua"] = true,
              ["${3rd}/luv/library"] = true,
            },
          },
        },
      },
    })

    vim.lsp.enable({
      "clangd",
      "lua_ls",
    })

    vim.diagnostic.config({
      severity_sort = true,
      underline = true,
      virtual_lines = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      virtual_text = {
        severity = { max = vim.diagnostic.severity.WARN },
      },
    })
  end,
}
