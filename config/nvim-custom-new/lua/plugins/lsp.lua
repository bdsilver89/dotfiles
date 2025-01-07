return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
    },
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local icons = require("config.icons")
      return {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            -- prefix = "●",
            prefix = vim.g.has_nerd_font and "󱓻 ",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
              [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
              [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
            },
          },
        },
        inlay_hints = {
          enabled = true,
          exclude = {},
        },
        codelens = {
          enabled = true,
        },
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        servers = {
          bashls = {},
          neocmake = {},
          clangd = {},
          lua_ls = {
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                  library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                    vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                    "${3rd}/luv/library",
                  },
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
          rust_analyzer = { enabled = false },
        },
      }
    end,
    config = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
        callback = function(event)
          local function map(lhs, rhs, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- stylua: ignore start
          if vim.g.picker == "fzf"  then
            map("gd", "<cmd>FzfLua lsp_definitions jump_to_single_result=true ignore_current_line=true<cr>", "defintion")
            map("gr", "<cmd>FzfLua lsp_references jump_to_single_result=true ignore_current_line=true<cr>", "references")
            map("gI", "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>", "implementations")
            map("gy", "<cmd>FzfLua lsp_typedefs jump_to_single_result=true ignore_current_line=true<cr>", "type implementations")
          elseif vim.g.picker == "telescope" then
            map("gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, "defintion")
            map("gr", function() require("telescope.builtin").lsp_references({ reuse_win = true }) end, "references")
            map("gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, "implementations")
            map("gy", function() require("telescope.builtin").lsp_type_implementations({ reuse_win = true }) end, "type implementations")
          else
            map("gd", vim.lsp.buf.definition, "defintion")
            map("gr", vim.lsp.buf.references, "references")
            map("gI", vim.lsp.buf.implementation, "implementations")
            map("gy", vim.lsp.buf.type_definition, "type implementations")
          end
          map("gK", vim.lsp.buf.signature_help, "signature help")
          map("<c-k>", vim.lsp.buf.signature_help, "signature help", "i")
          map("<leader>ca", vim.lsp.buf.code_action, "code actions")
          map("<leader>cr", vim.lsp.buf.rename, "rename")
          -- stylua: ignore end

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- additional server-specific keymaps
          -- local lspconfig_opts = {}
          -- local Config = require("lazy.core.config")
          -- local Plugin = require("lazy.core.plugin")
          -- local lspconfig = Config.spec.plugins["nvim-lspconfig"]
          -- if lspconfig then
          --   lspconfig_opts = Plugin.values(lspconfig, "opts", false)
          -- end
          --
          -- if client then
          --   for _, keymap in ipairs(lspconfig_opts.servers[client.name].keys or {}) do
          --     map(keymap[1], keymap[1], keymap[2])
          --   end
          -- end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("config_lsphighlight", { clear = false })
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
              buffer = event.buf,
              group = highlight_augroup,
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "config_lsphighlight", buffer = event2.buf })
              end,
            })
          end

          if
            opts.inlay_hints.enabled
            and client
            and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
          then
            if
              vim.api.nvim_buf_is_valid(event.buf)
              and vim.bo[event.buf].buftype == ""
              and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[event.buf].filetype)
            then
              vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            end

            map("<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Toggle inlay hints")
          end

          if
            opts.codelens.enabled
            and vim.lsp.codelens
            and client
            and client.supports_method(vim.lsp.protocol.Methods.textDocument_codeLens)
          then
            map("<leader>cc", vim.lsp.codelens.run, "run codelens")
            map("<leader>cR", vim.lsp.codelens.refresh, "refresh codelens")
          end
        end,
      })

      vim.diagnostic.config(opts.diagnostics)

      -- default border style
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = "rounded"
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      local servers = opts.servers
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            local sopts = vim.tbl_deep_extend("force", {
              capabilities = vim.deepcopy(capabilities),
            }, servers[server] or {})
            require("lspconfig")[server].setup(sopts)
          end
        end
      end
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    opts = {},
  },
}
