local Notify = require("config.utils.notify")

-- LSP word navigation
local W = {}

W.defaults = {
  enabled = true,
  debounce = 200,
  notify_jump = false,
  notify_end = true,
  foldopen = true,
  jumplist = true,
  modes = { "n", "i", "c" },
}

W.ns = vim.api.nvim_create_namespace("vim_lsp_references")
W.timer = vim.uv.new_timer()

function W.is_enabled(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local mode = vim.api.nvim_get_mode().mode:lower()
  mode = mode:gsub("\22", "v"):gsub("\19", "s")
  mode = mode:sub(1, 2) == "no" and "o" or mode
  mode = mode:sub(1, 1):match("[ncitsvo]") or "n"
  local clients = vim.lsp.get_clients({ bufnr = buf })
  clients = vim.tbl_filter(function(client)
    return client.supports_method("textDocument/documentHighlight", { bufnr = buf })
  end, clients)
  return W.defaults.enabled and vim.tbl_contains(W.defaults.modes, mode) and #clients > 0
end

function W.clear()
  vim.lsp.buf.clear_references()
end

function W.update()
  local buf = vim.api.nvim_get_current_buf()
  W.timer:start(W.defaults.debounce, 0, function()
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_call(buf, function()
          if not W.is_enabled() then
            return
          end
          vim.lsp.buf.document_highlight()
          W.clear()
        end)
      end
    end)
  end)
end

function W.get()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current, ret = nil, {}
  for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(0, W.ns, 0, -1, { details = true })) do
    local w = {
      from = { extmark[2] + 1, extmark[3] },
      to = { extmark[4].end_row + 1, extmark[4].end_col },
    }
    ret[#ret + 1] = w
    if cursor[1] >= w.from[1] and cursor[1] <= w.to[1] and cursor[2] >= w.from[2] and cursor[2] <= w.to[2] then
      current = #ret
    end
  end
  return ret, current
end

function W.jump(count, cycle)
  local words, idx = W.get()
  if not idx then
    return
  end
  idx = idx + count
  if cycle then
    idx = (idx - 1) % #words + 1
  end
  local target = words[idx]
  if target then
    if W.defaults.jumplist then
      vim.cmd.normal({ "m`", bang = true })
    end
    vim.api.nvim_win_set_cursor(0, target.from)
    if W.defaults.notify_jump then
      Notify.info(("Reference [%d/%d]"):format(idx, #words), { title = "Words" })
    end
    if W.defaults.foldopen then
      vim.cmd.normal({ "zv", bang = true })
    end
  elseif W.defaults.notify_end then
    Notify.warn("No more references", { title = "Words" })
  end
end

function W.setup()
  local group = vim.api.nvim_create_augroup("lsp_words", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged" }, {
    group = group,
    callback = function()
      if not W.is_enabled() then
        W.clear()
        return
      end
      if not ({ W.get() })[2] then
        W.update()
      end
    end,
  })
end

local function on_attach(_, buffer)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = "LSP: " .. desc })
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
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "List workspace folders")
  -- map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map({ "n", "v" }, "<leader>ca", "<cmd>FzfLua lsp_code_actions<cr>", "Code action")
  map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>cl", "<cmd>LspInfo<cr>", "Info")

  map("n", "<leader>cs", vim.lsp.buf.document_symbol, "symbols (document)")
  map("n", "<leader>cS", vim.lsp.buf.workspace_symbol, "symbols (workspace)")

  map("n", "]]", function()
    W.jump(vim.v.count1)
  end, "Next reference")
  map("n", "[[", function()
    W.jump(-vim.v.count1)
  end, "Next reference")
end

local function on_init(client, _)
  if client.supports_method("textDocument/semanticTokens") then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    -- NOTE: this cannot have a mason dependency for the current version of masoninstallall command
    -- that depends on this loading to configure itself first...
    config = function()
      -- diagnostic config
      local x = vim.diagnostic.severity

      vim.diagnostic.config({
        virtual_text = { prefix = "" },
        signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "", [x.INFO] = "󰋼", [x.HINT] = "󰌵" } },
        underline = true,
        float = { border = "single" },
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

      W.setup()

      local servers = { "bashls", "clangd", "jdtls", "jsonls", "neocmake", "ruff", "tailwindcss", "vtsls" }

      for _, lsp in ipairs(servers) do
        require("lspconfig")[lsp].setup({
          on_attach = on_attach,
          capabilities = capabilities,
          on_init = on_init,
        })
      end

      require("lspconfig").lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        on_init = on_init,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                vim.fn.expand("$VIMRUNTIME/lua"),
                vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types",
                vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                "${3rd}/luv/library",
              },
              maxPreload = 100000,
              preloadFileSize = 10000,
            },
          },
        },
      })
    end,
  },
}
