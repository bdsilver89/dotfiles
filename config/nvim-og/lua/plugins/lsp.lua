return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      { "williamboman/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      return {
        servers = {},
        setup = {},
        diagnostics = {
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = "󰅚 ",
              [vim.diagnostic.severity.WARN] = "󰀪 ",
              [vim.diagnostic.severity.INFO] = "󰋽 ",
              [vim.diagnostic.severity.HINT] = "󰌶 ",
            },
          },
          underline = true,
          update_in_insert = false,
          -- virtual_lines = { current_line = true },
          virtual_text = {
            -- prefix = "󱓻",
            -- prefix = "●",
          },
        },
      }
    end,
    config = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP settings",
        group = vim.api.nvim_create_augroup("bdsilver89/lspattach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then
            return
          end

          -- if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
          --   vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          -- end

          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { desc = desc, buffer = ev.buf })
          end

          map("gd", vim.lsp.buf.definition, "vim.lsp.buf.definition")
          map("gD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration")
          map("gW", vim.lsp.buf.workspace_symbol, "vim.lsp.buf.workspace_symbol")

          if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].buftype == "" then
              vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            end
          end

          if client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
          end

          if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = ev.buf,
              callback = vim.lsp.codelens.refresh,
            })
          end

          if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, ev.buf) then
            local hl_augroup = vim.api.nvim_create_augroup("bdsilver89/lsphighlight", { clear = true })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = ev.buf,
              group = hl_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = ev.buf,
              group = hl_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("bdsilver89/lsphighlightdetach", { clear = true }),
              callback = function(ev2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "bdsilver89/lsphighlight", buffer = ev2.buf })
              end,
            })
          end

          vim.diagnostic.config({
            severity_sort = true,
            signs = {
              text = {
                [vim.diagnostic.severity.ERROR] = "󰅚 ",
                [vim.diagnostic.severity.WARN] = "󰀪 ",
                [vim.diagnostic.severity.INFO] = "󰋽 ",
                [vim.diagnostic.severity.HINT] = "󰌶 ",
              },
            },
            underline = true,
            update_in_insert = false,
            -- virtual_lines = { current_line = true },
            virtual_text = {
              -- prefix = "󱓻",
              -- prefix = "●",
            },
          })
        end,
      })

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      if opts.capabilities then
        vim.lsp.config("*", { capabilities = opts.capabilities })
      end

      local mason_all = vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
      local mason_exclude = {}

      local function configure(server)
        local sopts = opts.servers[server]
        sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup["*"]
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts)
          if not use_mason then
            vim.lsp.enable(server)
          end
        end
        return use_mason
      end

      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
      require("mason-lspconfig").setup({
        ensure_installed = install,
        automatic_enable = { exclude = mason_exclude },
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {},
    },
    config = function(_, opts)
      require("mason").setup()
      local mr = require("mason-registry")
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
