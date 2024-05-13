return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "folke/neoconf.nvim",
        cmd = "Neoconf",
        opts = {},
        -- config = false,
        dependencies = { "nvim-lspconfig" },
      },
      {
        "folke/neodev.nvim",
        opts = {},
        enabled = vim.g.enable_lua_support,
      },
      "williamboman/mason.nvim",
      {
        "williamboman/mason-lspconfig.nvim",
        enabled = vim.g.enable_mason_packages,
      },
      {
        "j-hui/fidget.nvim",
        opts = {},
      },
      {
        "smjonas/inc-rename.nvim",
        opts = {},
      },
    },
    opts = function()
      local Icons = require("config.icons")
      return {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            -- prefix = "●",
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
        },
        inlay_hints = {
          enabled = true,
        },
        codelens = {
          enabled = true,
        },
        servers = {},
        setup = {},
      }
    end,
    config = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
        callback = function(event)
          local buffer = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- keymaps
          local function map(mode, lhs, rhs, kopts, has)
            local modes = type(mode) == "string" and { mode } or mode
            if has ~= nil then
              has = has:find("/") and has or "textDocument/" .. has
              if not client.supports_method(has) then
                return
              end
            end
            kopts.desc = kopts.desc and "LSP " .. kopts.desc or kopts.desc
            vim.keymap.set(modes, lhs, rhs, vim.tbl_deep_extend("force", { buffer = buffer }, kopts or {}))
          end

          -- stylua: ignore start
          map("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "info" })
          map("n", "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end,
            { desc = "goto definition" }, "definition")
          map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "references" })
          map("n", "gD", vim.lsp.buf.declaration, { desc = "goto declaration" })
          map("n", "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end,
            { desc = "goto implementation" })
          map("n", "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end,
            { desc = "goto type definition" })
          map("n", "K", vim.lsp.buf.hover, { desc = "hover" })
          map("n", "gK", vim.lsp.buf.signature_help, { desc = "signature help" }, "signatureHelp")
          map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "signature help" }, "signatureHelp")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "code action" }, "codeAction")
          map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, { desc = "run codelens" }, "codeLens")
          map("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "refresh and display codelens" }, "codeLens")
          map(
            "n",
            "<leader>cA",
            function()
              vim.lsp.buf.code_action({
                context = {
                  only = {
                    "source",
                  },
                  diagnostics = {},
                }
              })
            end,
            { desc = "source action" },
            "codeAction")
          map(
            "n",
            "<leader>cr",
            function()
              local inc_rename = require("inc_rename")
              return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
            end,
            { desc = "rename", expr = true })
          -- stylua: ignore end

          -- TODO: inlay hints
          -- if opts.inlay_hints.enabled then
          --   if client.supports_method("textDocument/inlayHint") then
          --     local function toggle_inlay_hint(buf, value)
          --       local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
          --       if type(ih) == "function" then
          --         ih(buf, value)
          --       elseif type(ih) == "table" and ih.enable then
          --         if value == nil then
          --           value = not ih.is_enabled(buf)
          --         end
          --         ih.enable(value { bufnr = buf })
          --       end
          --     end
          --
          --     toggle_inlay_hint(buffer, true)
          --     map("n", "<leader>ch", function()
          --       toggle_inlay_hint(vim.api.nvim_get_current_buf())
          --     end, "toggle inlay hints")
          --   end
          -- end

          -- code lens
          -- if opts.codelens.enabled and client.supports_method("textDocument/codeLens") then
          --   vim.lsp.codelens.refresh()
          -- end
        end,
      })

      -- diagnostic signs
      if vim.fn.has("nvim-0.10") == 0 then
        for severity, icon in pairs(opts.diagnostics.signs.text) do
          local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
          name = "DiagnosticSign" .. name
          vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
        end
      end

      -- diagnostic virtual text

      -- diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- server setup
      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      -- get all the servers that are available through mason-lspconfig
      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mlsp_servers = {}
      if have_mason then
        all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(all_mlsp_servers, server) then
            setup(server)
          elseif server_opts.enabled ~= false then
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mason then
        mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
      end
    end,
  }
}
