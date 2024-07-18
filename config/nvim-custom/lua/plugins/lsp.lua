return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "j-hui/fidget.nvim", opts = {} },
      { "williamboman/mason-lspconfig.nvim", enabled = not vim.g.prefer_git, config = function() end },
    },
    opts = {
      servers = {},
      setup = {},
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "Goto definition")
          map("gr", require("telescope.builtin").lsp_references, "Goto references")
          map("gD", vim.lsp.buf.declaration, "Goto definition")
          map("gI", require("telescope.builtin").lsp_implementations, "Goto implementation")
          map("gy", require("telescope.builtin").lsp_type_definitions, "Goto type defintion")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("<leader>cl", "<cmd>LspInfo<cr>", "Info")

          -- word highlight
          if client and client.server_capabilities.documentHighlightProvider then
            local group = vim.api.nvim_create_augroup("config_lsp_highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = buf,
              group = group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = buf,
              group = group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              buffer = buf,
              group = group,
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "config_lsp_highlight", buffer = event2.buf })
              end,
            })
          end

          -- inlay hints
          if client and client.supports_method("textDocument/inlayHint", { bufnr = buf }) then
            local function toggle_inlay_hint(val)
              if val == nil then
                val = not vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
              end
              vim.lsp.inlay_hint.enable(val, { bufnr = buf })
            end

            toggle_inlay_hint(true)
            map("<leader>uh", toggle_inlay_hint, "Toggle inlay hint")
          end

          -- codelens
          -- if client and client.supports_method("textDocument/codeLens", { bufnr = buf }) then
          --   vim.lsp.codelens.refresh()
          --   vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
          --     buffer = buf,
          --     callback = vim.lsp.codelens.refresh,
          --   })
          -- end
        end,
      })

      -- diagnostic setup
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = vim.g.enable_icons and " " or "E",
            [vim.diagnostic.severity.WARN] = vim.g.enable_icons and " " or "W",
            [vim.diagnostic.severity.HINT] = vim.g.enable_icons and " " or "H",
            [vim.diagnostic.severity.INFO] = vim.g.enable_icons and " " or "I",
          },
        },
      })

      local servers = opts.servers

      local cmp_avail, cmp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_avail and cmp.default_capabilities() or {}
      )

      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mlsp_servers = {}
      if have_mason then
        all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local use_mason = false
      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        end

        -- prevent mason-disabled lspconfig from trying to setup a lsp that is not in the PATH
        local should_setup = true
          if
            not use_mason
            and vim.fn.executable( require("lspconfig.server_configurations." .. server).default_config.cmd[1]) == 0
          then
          should_setup = false
        end

        if should_setup then
          require("lspconfig")[server].setup(server_opts)
        end
      end

      -- using mason-tool-installer offloads mason-lspconfig setup here
      -- language pack files now set that up separately from lspconfig
      -- when mason is disabled, lspconfig setup is easier to deal with
      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        server_opts = server_opts and (server_opts == true and {} or server_opts) or {}
        if
          server_opts.enabled ~= false
          -- and (vim.g.enable_mason_packages or
          -- and (vim.fn.executable(require("lspconfig")[server].cmd) == 1)
        then
          if server_opts.mason == false or not vim.tbl_contains(all_mlsp_servers, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mason then
        use_mason = true
        mlsp.setup({
          ensure_installed = vim.tbl_deep_extend("force", ensure_installed, {}),
          handlers = { setup },
        })
      end
    end,
  },
}
