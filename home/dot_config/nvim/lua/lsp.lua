local diagnostic_icons = require("icons").diagnostics

vim.g.inlay_hints = false

---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts string|vim.keymap.set.Opts
  ---@param mode? string|string[]
  local function map(lhs, rhs, opts, mode)
    mode = mode or "n"
    ---@cast opts vim.keymap.set.Opts
    opts = type(opts) == "string" and { desc = opts } or opts
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  map("[e", function()
    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
  end, "Prev error")
  map("]e", function()
    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
  end, "Next error")
  map("[w", function()
    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })
  end, "Prev warning")
  map("]w", function()
    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })
  end, "Next warning")

  if client:supports_method("textDocument/documentColor") then
    vim.lsp.document_color.enable(true, { bufnr = bufnr })
  end

  if client:supports_method("textDocument/references") then
    map("grr", "<cmd>FzfLua lsp_references<cr>", "References")
  end

  if client:supports_method("textDocument/typeDefinition") then
    map("gy", "<cmd>FzfLua lsp_typedefs<cr>", "Type definition")
  end

  if client:supports_method("textDocument/typeDefinition") then
    map("<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", "Document symbols")
    map("<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", "Workspace symbols")
  end

  if client:supports_method("textDocument/definition") then
    map("gd", "<cmd>FzfLua lsp_definitions jump1=treu ignore_current_line<cr>", "Goto definition")
  end

  if client:supports_method("textDocument/documentHighlight") then
    local group = vim.api.nvim_create_augroup("cursorhl", { clear = false })
    vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertLeave", "BufLeave" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  if client:supports_method("textDocument/inlayHint") then
    local group = vim.api.nvim_create_augroup("inlayhinthl", { clear = false })

    if vim.g.inlay_hints then
      vim.defer_fn(function()
        local mode = vim.api.nvim_get_mode().mode
        vim.lsp.inlay_hint.enable(mode == "n" or mode == "v", { bufnr = bufnr })
      end, 500)
    end

    vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      buffer = bufnr,
      callback = function()
        if vim.g.inlay_hints then
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        end
      end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,
      buffer = bufnr,
      callback = function()
        if vim.g.inlay_hints then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end,
    })
  end
end

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  virtual_text = true,
  virtual_lines = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = diagnostic_icons.ERROR,
      [vim.diagnostic.severity.WARN] = diagnostic_icons.WARN,
      [vim.diagnostic.severity.HINT] = diagnostic_icons.HINT,
      [vim.diagnostic.severity.INFO] = diagnostic_icons.INFO,
    },
  },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.jump({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    on_attach(client, ev.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })

    local servers = vim
      .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
      :map(function(file)
        return vim.fn.fnamemodify(file, ":t:r")
      end)
      :totable()
    vim.lsp.enable(servers)
  end,
})
