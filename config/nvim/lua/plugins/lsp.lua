return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim",       opts = {} },
      { "folke/neodev.nvim",       opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
        callback = function(event)
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gr", require("telescope.builtin").lsp_references, "Goto references")
          map("gI", require("telescope.builtin").lsp_implementations, "Goto implmentation")

          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")

          map("K", vim.lsp.buf.hover, "Hover documentation")


          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("config_lsp_highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("config_lsp_detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "config_lsp_highlight", buffer = event2.buf })
              end,
            })
          end

          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map("<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, "Toggle inlay hint")
          end

          if client and client.supports_method("textDocument/codeLens") then
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = event.buf,
              callback = vim.lsp.codelens.refresh,
            })
          end
        end,
      })

      -- diagnostic signs
      local Ui = require("config.ui")
      for _, name in ipairs({ "Error", "Warn", "Hint", "Info" }) do
        local sign = "DiagnosticSign" .. name
        vim.fn.sign_define(sign, { text = Ui.get_icon("diagnostics", name), texthl = sign, numhl = "" })
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        clangd = {},
        ["neocmakelsp"] = {},

        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        --

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
