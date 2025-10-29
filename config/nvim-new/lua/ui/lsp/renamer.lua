local function get_text_at_range(range, position_encoding)
  return vim.api.nvim_buf_get_text(
    0,
    range.start_line,
    vim.lsp.util._get_line_byte_from_position(0, range.start, position_encoding),
    range["end"].line,
    vim.lsp.util._get_line_byte_from_position(0, range["end"], position_encoding),
    {}
  )[1]
end

local function get_symbol_to_rename(cb)
  local cword = vim.fn.expand("<cword>")
  local clients = vim.lsp.get_clients({ bufnr = 0, method = vim.lsp.protocol.Methods.textDocument_rename })

  if #clients == 0 then
    cb(cword)
    return
  end

  table.sort(clients, function(a, b)
    return a:supports_method(vim.lsp.protocol.Methods.textDocument_prepareRename)
        and not b:supports_method(vim.lsp.protocol.Methods.textDocument_prepareRename)
  end)

  local client = clients[1]

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_prepareRename) then
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

    client:request(vim.lsp.protocol.Methods.textDocument_prepareRename, params, function(err, result, _, _)
      if err or not result then
        cb(cword)
      end

      local symbol_text = cword

      if result.placeholder then
        symbol_text = result.placeholder
      elseif result.start then
        symbol_text = get_text_at_range(result, client.offset_encoding)
      elseif result.range then
        symbol_text = get_text_at_range(result.range, client.offset_encoding)
      end

      cb(symbol_text)
    end, 0)
  else
    cb(cword)
  end
end

return function()
  get_symbol_to_rename(function(to_rename)
    local buf = vim.api.nvim_create_buf(false, true)

    local winopts = {
      height = 1,
      style = "minimal",
      -- border
      row = 1,
      col = 1,
      relative = "cursor",
      width = #to_rename + 15,
      title = { { " Rename ", "@comment.danger" } },
      title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, winopts)
    -- vim.wo[win].winhl
    vim.api.nvim_set_current_win(win)

    vim.api.nvim_buf_set_lines(buf, 0, -1, true, { " " .. to_rename })

    vim.bo[buf].buftype = "prompt"
    vim.fn.prompt_setprompt(buf, "")
    vim.api.nvim_input("A")

    vim.keymap.set({ "i", "n" }, "<esc>", function()
      vim.api.nvim_buf_delete(buf, { force = true })
    end, { buffer = buf })

    vim.fn.prompt_setcallback(buf, function(text)
      local new_name = vim.trim(text)
      vim.api.nvim_buf_delete(buf, { force = true })

      if #new_name > 0 and new_name ~= to_rename then
        local params = vim.lsp.util.make_position_params(0, "utf-8")
        params = vim.tbl_extend("force", params, { newName = new_name })
        vim.lsp.buf_request(0, vim.lsp.protocol.Methods.textDocument_rename, params)
      end
    end)
  end)
end
