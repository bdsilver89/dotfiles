-- need to add mason install dir to path for LSP executables WITHOUT loading mason.nvim
local is_windows = vim.fn.has("win32") == 1
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH

-- automatically enable LSP configs found in rtp
local configs = {}
for _, v in ipairs(vim.api.nvim_get_runtime_file("lsp/*", true)) do
  local name = vim.fn.fnamemodify(v, ":t:r")
  configs[#configs + 1] = name
end

vim.lsp.enable(configs)

local methods = vim.lsp.protocol.Methods

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Configure LSP settings",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    local function map(lhs, rhs, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end

    -- keymaps
    map("gra", "<cmd>FzfLua lsp_code_actions<cr>", "vim.lsp.buf.code_action()", { "n", "x" })
    map("grr", "<cmd>FzfLua lsp_references<cr>", "vim.lsp.buf.references()")
    map("gy", "<cmd>FzfLua lsp_typedefs<cr>", "vim.lsp.buf.type_definition()")
    map("<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", "Document symbols")

    if client:supports_method(methods.textDocument_definition) then
      map("gd", function()
        require("fzf-lua").lsp_definitions({ jump1 = true })
      end, "Go to definition")

      map("gD", function()
        require("fzf-lua").lsp_definitions({ jump1 = false })
      end, "Peek definition")
    end

    if client:supports_method(methods.textDocument_documentHighlight) then
      local under_cursor_highlights_group =
        vim.api.nvim_create_augroup("bdsilver89/cursor_highlights", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
        group = under_cursor_highlights_group,
        desc = "Highlight references under the cursor",
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
        group = under_cursor_highlights_group,
        desc = "Clear highlight references",
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if client:supports_method(methods.textDocument_inlayHint) and vim.g.inlay_hints then
      local inlay_hints_group = vim.api.nvim_create_augroup("bdsilver89/toggle_inlay_hints", { clear = false })

      vim.defer_fn(function()
        local mode = vim.api.nvim_get_mode().mode
        vim.lsp.inlay_hint.enable(mode == "n" or mode == "v", { bufnr = args.buf })
      end, 500)

      vim.api.nvim_create_autocmd("InsertEnter", {
        group = inlay_hints_group,
        desc = "Enable inlay hints",
        buffer = args.buf,
        callback = function()
          if vim.g.inlay_hints then
            vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
          end
        end,
      })

      vim.api.nvim_create_autocmd("InsertLeave", {
        group = inlay_hints_group,
        desc = "Disable inlay hints",
        buffer = args.buf,
        callback = function()
          if vim.g.inlay_hints then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })
    end

    -- diagnostic config
    local icons = require("icons")
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      signs = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.ERROR,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.WARN,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.HINT,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.INFO,
      },
      virtual_text = {
        spacing = 4,
        source = "if_many",
      },
      float = {
        source = "if_many",
      },
      severity_sort = true,
    })
  end,
})
