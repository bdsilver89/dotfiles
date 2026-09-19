vim.diagnostic.config({
  severity_sort = true,
  virtual_lines = {
    current_line = true,
    overflow = "wrap",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      }
    end,
  },
})

local group = vim.api.nvim_create_augroup("configlsp", { clear = true })

-- vim.api.nvim_create_autocmd("LspProgress", {
--   group = group,
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     local value = ev.data.params.value
--     local token = ev.data.params.token or "default"
--     local icon = value.kind == "end" and "" or ""
--     local text = value.message or (value.kind == "end" and "Done" or "Loading...")
--     local client_name = client and client.name or "LSP"
--     local display_str = string.format("[%s] %s %s: %s", client_name, icon, value.title or "", text)
--     vim.api.nvim_echo({ { display_str } }, false, {
--       id = "lsp_progress_" .. ev.data.client_id .. "_" ..tostring(token),
--       kind = "progress",
--       source = "vim.lsp",
--       title = value.title,
--       status = value.kind ~= "end" and "running" or "success",
--       percent = value.percent,
--     })
--   end,
-- })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc, buf = ev.buf })
    end

    map("gd", vim.lsp.buf.definition, "vim.lsp.buf.definition()")
    map("gD", vim.lsp.buf.declaration, "vim.lsp.buf.declaration()")
    map("gW", vim.lsp.buf.workspace_symbol, "vim.lsp.buf.workspace_symbol()")

    if client:supports_method("textDocument/inlayHint", ev.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, "Toggle inlay hint")
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    local servers = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
      :map(function(file)
        return vim.fn.fnamemodify(file, ":t:r")
      end)
      :filter(function(server)
        return server ~= "jdtls"
      end)
      :totable()
    vim.list_extend(servers, {
      "tsc",
      "tailwindcss",
    })
    vim.lsp.enable(servers)
  end,
})
