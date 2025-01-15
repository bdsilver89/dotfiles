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

function M.keymap_setup(client, buffer)
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
  elseif vim.g.picker == "snacks" then
    map(buffer, "n", "gd", function() Snacks.picker.lsp_definitions() end, "defintion")
    map(buffer, "n", "gr", function() Snacks.picker.lsp_references() end, "references")
    map(buffer, "n", "gI", function() Snacks.picker.lsp_implementations() end, "implementations")
    map(buffer, "n", "gy", function() Snckas.picker.lsp_type_definitions() end, "type implementations")
    map(buffer, "n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, "symbols")
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

  if
    client
    and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
    and Snacks.words.is_enabled()
  then
    map(buffer, "n", "]]", function() Snacks.words.jump(vim.v.count1) end,"next refernece")
    map(buffer, "n", "[[", function() Snacks.words.jump(-vim.v.count1) end,"prev refernece")
  end

  if
    vim.lsp.codelens
    and client
    and client.supports_method(vim.lsp.protocol.Methods.textDocument_codeLens)
  then
    map(buffer, { "n", "v" }, "<leader>cc", vim.lsp.codelens.run, "run codelens")
    map(buffer, { "n", "v" }, "<leader>cC", vim.lsp.codelens.refresh, "refresh codelens")
  end
  -- stylua: ignore end
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

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("config_lspattach", { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      local buffer = event.buf

      M.keymap_setup(client, buffer)
      M.inlay_hint_setup(client, buffer)
    end,
  })
end

return M
