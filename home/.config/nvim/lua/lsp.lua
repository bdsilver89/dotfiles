vim.diagnostic.config({
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  virtual_text = true,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

vim.lsp.enable({
  -- "bash",
  "clangd",
  "jdtls",
  -- "jsonls",
  "lua_ls",
  "rust_analyzer",
  "tsc",
  -- "yamlls",
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf })
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, { buffer = ev.buf })

    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      vim.keymap.set("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, { buffer = ev.buf })
    end
  end,
})

local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local i_frame = 0
local message_id = nil

vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("config_lspprogress", { clear = true }),
  callback = function(ev)
    local value = ev.data.params.value
    if value == nil then
      return
    end

    local title = value.title
    local percent = value.percentage or 0
    local is_running = true

    if percent > 95 and percent <= 100 then
      is_running = false
    end

    if percent > 0 then
      local status = is_running and "running" or "success"

      if i_frame == #frames then
        i_frame = 0
      end
      i_frame = i_frame + 1

      message_id = vim.api.nvim_echo({ { title } }, false, {
        id = message_id,
        percent = percent,
        source = "lsp-progress",
        status = status,
        title = frames[i_frame] .. " LSP",
        kind = "progress",
      })
    end
  end,
})
