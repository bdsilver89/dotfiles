local M = {}

local function map(buffer, mode, lhs, rhs, desc)
  mode = mode or "n"
  vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = "LSP: " .. desc })
end

local function renamer()
  local var = vim.fn.expand("<cword>")
  local buf = vim.api.nvim_create_buf(false, true)
  local opts = { height = 1, style = "minimal", border = "rounded", row = 1, col = 1 }

  opts.relative = "cursor"
  opts.width = #var + 15
  opts.title = { { " Rename ", "@comment.danger" } }
  opts.title_pos = "center"

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.wo[win].winhl = "Normal:Normal,FloatBorder:Removed"
  vim.api.nvim_set_current_win(win)

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, { " " .. var })

  vim.bo[buf].buftype = "prompt"
  vim.fn.prompt_setprompt(buf, "")
  vim.api.nvim_input("A")

  vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>q!<cr>", { buffer = buf })

  vim.fn.prompt_setcallback(buf, function(text)
    local new_name = vim.trim(text)
    vim.api.nvim_buf_delete(buf, { force = true })

    if #new_name > 0 and new_name ~= var then
      local params = vim.lsp.util.make_position_params()
      params.newName = new_name
      vim.lsp.buf_request(0, "textDocument/rename", params)
    end
  end)
end

function M.keymap_setup(_, buffer)
  -- stylua: ignore start
  if vim.g.picker == "fzf"  then
    map(buffer, "n", "gd", "<cmd>FzfLua lsp_definitions jump_to_single_result=true ignore_current_line=true<cr>", "defintion")
    map(buffer, "n", "gr", "<cmd>FzfLua lsp_references jump_to_single_result=true ignore_current_line=true<cr>", "references")
    map(buffer, "n", "gI", "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>", "implementations")
    map(buffer, "n", "gy", "<cmd>FzfLua lsp_typedefs jump_to_single_result=true ignore_current_line=true<cr>", "type implementations")
  elseif vim.g.picker == "telescope" then
    map(buffer, "n", "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, "defintion")
    map(buffer, "n", "gr", function() require("telescope.builtin").lsp_references({ reuse_win = true }) end, "references")
    map(buffer, "n", "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, "implementations")
    map(buffer, "n", "gy", function() require("telescope.builtin").lsp_type_implementations({ reuse_win = true }) end, "type implementations")
  else
    map(buffer, "n", "gd", vim.lsp.buf.definition, "defintion")
    map(buffer, "n", "gr", vim.lsp.buf.references, "references")
    map(buffer, "n", "gI", vim.lsp.buf.implementation, "implementations")
    map(buffer, "n", "gy", vim.lsp.buf.type_definition, "type implementations")
  end
  map(buffer, "n", "gK", vim.lsp.buf.signature_help, "signature help")
  map(buffer, "i", "<c-k>", vim.lsp.buf.signature_help, "signature help")
  map(buffer, "n", "<leader>ca", vim.lsp.buf.code_action, "code actions")
  map(buffer, "n", "<leader>cr", renamer, "rename")
  -- stylua: ignore end
end

function M.document_highlight_setup(client, buffer)
  if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
    local highlight_augroup = vim.api.nvim_create_augroup("config_lsphighlight", { clear = false })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = buffer,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = buffer,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      buffer = buffer,
      group = highlight_augroup,
      callback = function(event)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds({ group = "config_lsphighlight", buffer = event.buf })
      end,
    })
  end
end

function M.inlay_hint_setup(client, buffer)
  if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
    if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" then
      vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
    end

    map(buffer, "n", "<leader>uh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buffer }))
    end, "Toggle inlay hints")
  end
end

function M.codelens_setup(client, buffer)
  if vim.lsp.codelens and client and client.supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
    map(buffer, "n", "<leader>cc", vim.lsp.codelens.run, "run codelens")
    map(buffer, "n", "<leader>cR", vim.lsp.codelens.refresh, "refresh codelens")
  end
end

-- function M.signature_help_setup(client, buffer)
--   if
--     client
--     and client.server_capabilities.signatureHelpProvider
--     and client.server_capabilities.signatureHelpProvider.triggerCharacters
--   then
--     local group = vim.api.nvim_create_augroup("config_lspsignature", { clear = false })
--     vim.api.nvim_clear_autocmds({ group = group, buffer = buffer })
--
--     local trigger_chars = client.server_capabilities.signatureHelpProvider.triggerCharacters
--
--     vim.api.nvim_create_autocmd("TextChangedI", {
--       group = group,
--       buffer = buffer,
--       callback = function()
--         local cur_line = vim.api.nvim_get_current_line()
--         local pos = vim.api.nvim_win_get_cursor(0)[2]
--         local prev_char = cur_line:sub(pos - 1, pos - 1)
--         local cur_char = cur_line:sub(pos, pos)
--
--         for _, char in ipairs(trigger_chars) do
--           if cur_char == char or prev_char == char then
--             vim.lsp.buf.signature_help()
--             break
--           end
--         end
--       end,
--     })
--   end
-- end

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      local buffer = event.buf

      M.keymap_setup(client, buffer)
      M.document_highlight_setup(client, buffer)
      M.inlay_hint_setup(client, buffer)
      M.codelens_setup(client, buffer)
      -- M.signature_help_setup(client, buffer)
    end,
  })
end

return M
