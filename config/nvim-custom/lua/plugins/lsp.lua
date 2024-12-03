return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
    },
    -- NOTE: this cannot have a mason dependency for the current version of masoninstallall command
    -- that depends on this loading to configure itself first...
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
        callback = function(event)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- NOTE: these assume fzf-lua for now...

          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gr", vim.lsp.buf.references, "Show references")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
          map("n", "<leader>sh", vim.lsp.buf.signature_help, "Show signature help")
          map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
          map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

          map("n", "<leader>cs", vim.lsp.buf.document_symbol, "symbols (document)")
          map("n", "<leader>cS", vim.lsp.buf.workspace_symbol, "symbols (workspace)")

          map("n", "<leader>cq", function()
            vim.diagnostic.setqflist({ open = false })
            local win = vim.api.nvim_get_current_win()
            vim.cmd.copen()
            vim.api.nvim_set_current_win(win)
          end, "set loclist diagnostics")

          map("n", "<leader>cl", function()
            vim.diagnostic.setloclist({ open = false })
            local win = vim.api.nvim_get_current_win()
            vim.cmd.lopen()
            vim.api.nvim_set_current_win(win)
          end, "set loclist diagnostics")

          -- highlight word references in document
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_group = vim.api.nvim_create_augroup("config_lsp_highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("config_lsp_highlight_detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "config_lsp_highlight", buffer = event2.buf })
              end,
            })

            local ns = vim.api.nvim_create_namespace("vim_lsp_references")

            local function get()
              local cursor = vim.api.nvim_win_get_cursor(0)
              local current, ret = nil, {}
              for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(event.buf, ns, 0, -1, { details = true })) do
                local w = {
                  from = { extmark[2] + 1, extmark[3] },
                  to = { extmark[4].end_row + 1, extmark[4].end_col },
                }
                ret[#ret + 1] = w
                if
                  cursor[1] >= w.from[1]
                  and cursor[1] <= w.to[1]
                  and cursor[2] >= w.from[2]
                  and cursor[2] <= w.to[2]
                then
                  current = #ret
                end
              end
              return ret, current
            end

            local function jump(count, cycle)
              local words, idx = get()
              if not idx then
                return
              end
              idx = idx + count
              if cycle then
                idx = (idx - 1) % #words + 1
              end
              local target = words[idx]
              if target then
                -- add to jumplist
                vim.cmd.normal({ "m`", bang = true })

                vim.api.nvim_win_set_cursor(0, target.from)
                require("config.utils.notify").info(("Reference [%d/%d]"):format(idx, #words), { title = "References" })

                -- open foldcolumn
                vim.cmd.normal({ "zv", bang = true })
              else
                require("config.utils.notify").warn("No more references", { title = "References" })
              end
            end

            -- stylua: ignore start
            map("n", "]]", function() jump(vim.v.count1) end, "Next reference")
            map("n", "[[", function() jump(-vim.v.count1) end, "Next reference")
            -- stylua: ignore end
          end

          -- inlay hints
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("n", "<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "toggle inlay hints")
          end
        end,
      })

      -- diagnostic config
      local x = vim.diagnostic.severity

      local DiagnosticIcons = require("config.ui.icons.diagnostic")
      vim.diagnostic.config({
        virtual_text = { prefix = "" },
        signs = {
          text = {
            [x.ERROR] = DiagnosticIcons.Error,
            [x.WARN] = DiagnosticIcons.Warning,
            [x.INFO] = DiagnosticIcons.Info,
            [x.HINT] = DiagnosticIcons.Hint,
          },
        },
        underline = true,
        float = { border = "rounded" },
      })

      -- Default border style
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = "rounded"
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      -- signature helper
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
        focusable = false,
        silent = true,
        max_height = 7,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      local servers = {
        bashls = {},
        clangd = {},
        jsonls = {
          settings = {
            json = {
              schema = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = {
                  vim.fn.expand("$VIMRUNTIME/lua"),
                  vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                  vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                  "${3rd}/luv/library",
                },
              },
            },
          },
        },
        neocmake = {},
        ruff = {},
        vtsls = {},
      }

      require("mason").setup()

      -- additional tools
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        -- bash
        "shfmt",

        -- lua
        "stylua",

        -- python
        "black",
      })

      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },

  {
    "williamboman/mason.nvim",
    lazy = true,
    opts = {
      ui = {
        -- icons = {
        --   package_pending = " ",
        --   package_installed = "󰄳 ",
        --   package_uninstalled = " ",
        -- },
        border = "rounded",
      },
    },
  },
}
