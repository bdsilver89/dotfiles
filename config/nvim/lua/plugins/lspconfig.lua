-- local og_virt_text = nil
-- local og_virt_line = nil
--
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "mason.nvim",
    "mason-org/mason-lspconfig.nvim",
  },
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = false,
      severity_sport = true,
      virtual_text = {
        spacing = 4,
        source = "if_many",
      },
      -- virtual_lines = {
      --   current_line = true,
      -- },
      float = {
        border = "rounded",
        source = "if_many",
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = require("icons").diagnostics.ERROR,
          [vim.diagnostic.severity.WARN] = require("icons").diagnostics.WARN,
          [vim.diagnostic.severity.HINT] = require("icons").diagnostics.HINT,
          [vim.diagnostic.severity.INFO] = require("icons").diagnostics.INFO,
        },
      },
    },
    inlay_hints = {
      enabled = true,
    },
    codelens = {
      enabled = false,
    },
    servers = {},
    setup = {},
  },
  config = function(_, opts)
    local Utils = require("utils")

    Utils.lsp.on_attach(function(client, buffer)
      -- stylua: ignore
      local keymaps = {
        { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
        { "grr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
        { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
        { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
        { "grc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" } },
        { "grC", vim.lsp.codelens.refresh, desc = "Refresh Codelens", mode = { "n", "v" } },
        { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
        { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
        { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
        { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
        { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, desc = "Next Reference" },
        { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, desc = "Prev Reference" },
      }

      if opts.inlay_hints.enabled and client:supports_method("textDocument/inlayHint") then
        if
          vim.api.nvim_buf_is_valid(buffer)
          and vim.bo[buffer].buftype == ""
          and not vim.tbl_contains(opts.inlay_hints.exclude or {}, vim.bo[buffer].filetype)
        then
          vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
        end
      end

      if opts.codelens.enabled and client:supports_method("textDocument/codeLens") then
        vim.lsp.codelens.refresh()
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
          buffer = buffer,
          callback = vim.lsp.codelens.refresh,
        })
      end

      Utils.lazy_keymap(keymaps, buffer)
    end)

    vim.diagnostic.config(opts.diagnostics or {})
    -- vim.api.nvim_create_autocmd({ "CursorMoved", "DiagnosticChanged" }, {
    --   callback = function()
    --     if not vim.api.nvim_buf_is_valid(0) then
    --       return
    --     end
    --
    --     if og_virt_line == nil then
    --       og_virt_line = vim.diagnostic.config().virtual_lines
    --     end
    --
    --     if not (og_virt_line and og_virt_line.current_line) then
    --       if og_virt_text then
    --         vim.diagnostic.config({ virtual_text = og_virt_text })
    --         og_virt_text = nil
    --       end
    --       return
    --     end
    --
    --     if og_virt_text == nil then
    --       og_virt_text = vim.diagnostic.config().virtual_text
    --     end
    --
    --     local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    --
    --     if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
    --       vim.diagnostic.config({ virtual_text = og_virt_text })
    --     else
    --       vim.diagnostic.config({ virtual_text = false })
    --     end
    --   end,
    -- })
    --
    -- vim.api.nvim_create_autocmd("ModeChanged", {
    --   callback = function()
    --     if vim.api.nvim_buf_is_valid(0) then
    --       pcall(vim.diagnostic.show)
    --     end
    --   end,
    -- })

    local all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
    local ensure_installed = {}

    for k, v in pairs(opts.servers) do
      if v then
        v = v == true and {} or v
        vim.lsp.config(k, v)
        if v.mason == false or not vim.tbl_contains(all_mlsp_servers, k) then
          vim.lsp.enable(k)
        else
          ensure_installed[#ensure_installed + 1] = k
        end
      end
    end

    require("mason-lspconfig").setup({
      ensure_installed = ensure_installed,
    })
  end,
}
