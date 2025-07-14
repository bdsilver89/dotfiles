return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    {
      "mason-org/mason.nvim",
      build = ":MasonUpdate",
      keys = {
        { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
      },
      opts = {},
    },
    "mason-org/mason-lspconfig.nvim",
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      opts_extend = { "ensure_installed" },
      opts = {
        ensure_installed = {},
      },
    },
    { "j-hui/fidget.nvim", opts = {} },
    "saghen/blink.cmp",
  },
  opts = function()
    local Icons = require("config.icons")

    return {
      servers = {},
      diagnostics = {
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = Icons.diagnostics.ERROR,
            [vim.diagnostic.severity.WARN] = Icons.diagnostics.WARN,
            [vim.diagnostic.severity.INFO] = Icons.diagnostics.INFO,
            [vim.diagnostic.severity.HINT] = Icons.diagnostics.HINT,
          },
        },
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      },
    }
  end,
  config = function(_, opts)
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("bdsilver89/lsp", { clear = true }),
      callback = function(args)
        local buffer = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        -- stylua: ignore
        local keymaps = {
          { "grn", vim.lsp.buf.rename, desc = "Rename" },
          { "gra", vim.lsp.buf.code_action, mode = { "n", "x" }, desc = "Code Action" },
          { "grr", function() Snacks.picker.lsp_references() end, desc = "References" },
          { "gri", function() Snacks.picker.lsp_implementations() end, desc = "Implementations" },
          { "grd", function() Snacks.picker.lsp_definitions() end, desc = "Definitions" },
          { "grD", vim.lsp.buf.declaration, desc = "Declaration" },
          { "gO", function() Snacks.picker.lsp_symbols() end, desc = "Document Symbols" },
          { "gW", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },
          { "grt", function() Snacks.picker.lsp_type_definitions() end, desc = "Type Defintiions" },
          { "[[", function() Snacks.words.jump(vim.v.count1) end, desc = "Prev Reference"},
          { "]]", function() Snacks.words.jump(-vim.v.count1) end, desc = "Next Reference"},
        }

        -- Enable codelens if supported
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, buffer) then
          local group_name = "bdsilver89/codelenshl"
          local group = vim.api.nvim_create_augroup(group_name, { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = buffer,
            group = group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = buffer,
            group = group,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd("LspDetach", {
            buffer = buffer,
            group = group,
            callback = function(args2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = group_name, buffer = args2.buf })
            end,
          })
        end

        -- Enable inlay hints if supported
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, buffer) then
          if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end

        require("utils").lazy_keymap(keymaps)

        vim.diagnostic.config(opts.diagnostics)
      end,
    })

    local servers = opts.servers
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      require("blink.cmp").get_lsp_capabilities()
    )

    local ensure_installed = {}
    local all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings").get_all().lspconfig_to_package)
    for server, server_opts in pairs(servers) do
      if server.enabled ~= false then
        local shoud_install = server_opts.mason ~= false and vim.tbl_contains(all_mlsp_servers, server)
        if shoud_install then
          ensure_installed[#ensure_installed + 1] = server
        end

        server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})
        vim.lsp.config(server, server_opts)

        if not shoud_install then
          -- mason lspconfig usually handles this for us, but if we are bypassing mason,
          -- then we have to handle this ourselves
          vim.lsp.enable(server)
        end
      end
    end

    local plugin = require("lazy.core.config").spec.plugins["mason-tool-installer.nvim"]
    if plugin then
      vim.list_extend(
        ensure_installed,
        require("lazy.core.plugin").values(plugin, "opts", false).ensure_installed or {}
      )
    end

    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
    })

    require("mason-lspconfig").setup({
      ensure_installed = {},
      automatic_installation = false,
    })
  end,
}
