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
    "saghen/blink.cmp",
  },
  opts = {
    servers = {},
    diagnostics = {
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.has_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      } or {},
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
  },
  config = function(_, opts)
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("bdsilver89/lsp", { clear = true }),
      callback = function(args)
        local buffer = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        -- Enable inlay hints if supported
        if client:supports_method("textDocument/inlayHint") then
          if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end

        vim.diagnostic.config(opts.diagnostics)
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local blink_capabilities = require("blink.cmp").get_lsp_capabilities()

    local servers = opts.servers

    local function setup(server_name)
      local server = servers[server_name] or {}
      server.capabilities =
        vim.tbl_deep_extend("force", {}, capabilities, blink_capabilities, server.capabilities or {})
      require("lspconfig")[server_name].setup(server)
    end

    local ensure_installed = {}
    for server, server_opts in pairs(servers) do
      if server.enabled ~= false then
        if server_opts.mason == false then
          setup(server)
        else
          ensure_installed[#ensure_installed + 1] = server
        end
      end
    end

    local plugin = require("lazy.core.config").spec.plugins["mason-tool-installer.nvim"]
    if plugin then
      vim.list_extend(ensure_installed, require("lazy.core.plugin").values(plugin, "opts", false).ensure_installed or {})
    end

    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
    })

    require("mason-lspconfig").setup({
      ensure_installed = {},
      automatic_installation = false,
      handlers = { setup },
    })
  end,
}

