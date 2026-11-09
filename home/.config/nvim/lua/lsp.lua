vim.diagnostic.config({
  update_in_insert = false,
  underline = true,
  seveirty_sort = true,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
    format = function(diagnostic)
      return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
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
  "basedpyright",
  "bashls",
  "clangd",
  "jdtls",
  "jsonls",
  "lemminx",
  "lua_ls",
  "neocmake",
  "ruff",
  "rust_analyzer",
  "tsc",
  "yamlls",
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
    -- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf })
    -- vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, { buffer = ev.buf })

    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
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
