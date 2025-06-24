local Icons = require("config.icons")
local Utils = require("utils")

-- automatically enable LSPs found in rtp
local configs = {}
for _, v in ipairs(vim.api.nvim_get_runtime_file("lsp/*", true)) do
  local name = vim.fn.fnamemodify(v, ":t:r")
  configs[#configs + 1] = name
end
vim.lsp.enable(configs)

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
      { "<leader>cr", "<cmd>LspRestart<cr>", desc = "Lsp Restart" },
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

    if client:supports_method("textDocument/inlayHint") then
      if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" then
        vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
      end
    end

    -- if client:supports_method("textDocument/codeLens") then
    --   vim.lsp.codelens.refresh()
    --   vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    --     buffer = buffer,
    --     callback = vim.lsp.codelens.refresh,
    --   })
    -- end

    Utils.lazy_keymap(keymaps, buffer)

    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      virtual_text = true,
      -- virtual_lines = { current_line = true },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = Icons.diagnostics.ERROR,
          [vim.diagnostic.severity.WARN] = Icons.diagnostics.WARN,
          [vim.diagnostic.severity.HINT] = Icons.diagnostics.HINT,
          [vim.diagnostic.severity.INFO] = Icons.diagnostics.INFO,
        },
      },
      float = {
        focused = false,
        style = "minimal",
        source = true,
        header = "",
        prefix = "",
      },
      jump = { float = true },
    })
  end,
})

vim.api.nvim_create_user_command("LspRestart", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
  vim.defer_fn(function()
    vim.cmd("edit")
  end, 100)
end, { desc = "Restart LSPs" })

vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to `:checkhealth vim.lsp`" })
