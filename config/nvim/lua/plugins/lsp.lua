return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", opts = {} },
      { "folke/neodev.nvim", opts = {} },
      { "mason-tool-installer.nvim", optional = true },
      { "j-hui/fidget.nvim", opts = {} },
    },
    opts = {
      diagnostics = {},
      servers = {},
      setup = {},
    },
    config = function(_, opts)
      local Icons = require("config.icons")

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lspconfig_attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- keymaps
          local function map(l, r, desc)
            vim.keymap.set("n", l, r, { buffer = buf, desc = desc })
          end
          map("gd", require("telescope.builtin").lsp_definitions, "Goto definition")
          map("gr", require("telescope.builtin").lsp_references, "Goto references")
          map("gI", require("telescope.builtin").lsp_implementations, "Goto implementation")
          map("gD", vim.lsp.buf.declaration, "Goto definition")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")

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
              end
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
          if client and client.supports_method("textDocument/codeLens", { bufnr = buf }) then
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = buf,
              callback = vim.lsp.codelens.refresh,
            })
          end
        end
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, { border = "rounded", silent = true })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, { border = "rounded", silent = true })

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, { float = { border = "rounded" } })

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
            [vim.diagnostic.severity.ERROR] = Icons.get_icon("diagnostics", "Error"),
            [vim.diagnostic.severity.WARN] = Icons.get_icon("diagnostics", "Warn"),
            [vim.diagnostic.severity.HINT] = Icons.get_icon("diagnostics", "Hint"),
            [vim.diagnostic.severity.INFO] = Icons.get_icon("diagnostics", "Info"),
          },
        },
      })

      -- servers
      local servers = opts.servers
      local cmp_avail, cmp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_avail and cmp.default_capabilities() or {}
      )

      -- using mason-tool-installer offloads mason-lspconfig setup here
      -- language pack files now set that up separately from lspconfig
      -- when mason is disabled, lspconfig setup is easier to deal with
      for server, server_opts in pairs(servers) do
        server_opts = server_opts and (server_opts == true and {} or server_opts) or {}
        if server_opts.enabled ~= false
          -- and (vim.g.enable_mason_packages or
         -- and (vim.fn.executable(require("lspconfig")[server].cmd) == 1)
        then
          server_opts = vim.tbl_deep_extend("force", {
            capabilities = vim.deepcopy(capabilities)
          }, servers[server] or {})

          if opts.setup[server] then
            if opts.setup[server](server, server_opts) then
              return
            end
          end
          require("lspconfig")[server].setup(server_opts)
        end
      end
    end,
  },
}
