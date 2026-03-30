-- Native snippet loader + unified completion (LSP + snippets)
local snippet_dir = vim.fn.stdpath("config") .. "/snippets"
local function resolve_vscode_vars(body)
  local now = os.date("*t")
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  local filename = vim.fn.fnamemodify(filepath, ":t")
  local vars = {
    CURRENT_YEAR = tostring(now.year),
    CURRENT_YEAR_SHORT = string.format("%02d", now.year % 100),
    CURRENT_MONTH = string.format("%02d", now.month),
    CURRENT_MONTH_NAME = os.date("%B"),
    CURRENT_MONTH_NAME_SHORT = os.date("%b"),
    CURRENT_DATE = string.format("%02d", now.day),
    CURRENT_DAY_NAME = os.date("%A"),
    CURRENT_DAY_NAME_SHORT = os.date("%a"),
    CURRENT_HOUR = string.format("%02d", now.hour),
    CURRENT_MINUTE = string.format("%02d", now.min),
    CURRENT_SECOND = string.format("%02d", now.sec),
    CLIPBOARD = vim.fn.getreg("+"),
    RANDOM = string.format("%06d", math.random(999999)),
    UUID = vim.fn.system("uuidgen"):gsub("%s+$", ""),
    TM_FILENAME = filename,
    TM_FILEPATH = filepath,
    TM_DIRECTORY = vim.fn.fnamemodify(filepath, ":h"),
    TM_FILENAME_BASE = vim.fn.fnamemodify(filename, ":r"),
    TM_LINE_INDEX = tostring(vim.api.nvim_win_get_cursor(0)[1] - 1),
    TM_LINE_NUMBER = tostring(vim.api.nvim_win_get_cursor(0)[1]),
    TM_SELECTED_TEXT = (function()
      local ok, text = pcall(vim.fn.getreg, "v")
      return ok and text or ""
    end)(),
  }
  return (
    body
      :gsub("%${([%w_]+)}", function(name)
        return vars[name] or "${" .. name .. "}"
      end)
      :gsub("%$([%w_]+)", function(name)
        return vars[name] or "$" .. name
      end)
  )
end

local function load_file(path)
  local f = io.open(path, "r")
  if not f then
    return {}
  end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  if not ok or type(data) ~= "table" then
    return {}
  end
  local items = {}
  for _, snip in pairs(data) do
    if snip.prefix and snip.body then
      local body = type(snip.body) == "table" and table.concat(snip.body, "\n") or snip.body
      items[#items + 1] = { prefix = snip.prefix, body = body, description = snip.description or "" }
    end
  end
  return items
end

local function scan_dir(dir)
  local handle = vim.uv.fs_scandir(dir)
  if not handle then
    return {}
  end
  local files = {}
  while true do
    local name, typ = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    local full = dir .. "/" .. name
    if typ == "directory" then
      vim.list_extend(files, scan_dir(full))
    elseif name:match("%.json$") then
      files[#files + 1] = { path = full, name = name }
    end
  end
  return files
end

local function get_snippets(ft)
  local items = {}
  for _, file in ipairs(scan_dir(snippet_dir)) do
    local base = file.name:gsub("%.json$", "")
    if base == "global" or base == ft then
      vim.list_extend(items, load_file(file.path))
    end
  end
  return items
end

-- Kind icons for completion menu
local kind_icons = {
  Text = "󰉿",
  Method = "󰊕",
  Function = "󰊕",
  Constructor = "",
  Field = "󰜢",
  Variable = "󰀫",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "󰈇",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "󰙅",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "",
}

local function apply_kind_icons(items)
  for _, item in ipairs(items) do
    local icon = kind_icons[item.kind]
    if icon then
      item.kind = icon .. " " .. item.kind
    end
  end
  return items
end

-- Snippet completion items for a given prefix
local function snippet_matches(ft, prefix)
  local items = {}
  for _, snip in ipairs(get_snippets(ft)) do
    if prefix == "" or snip.prefix:sub(1, #prefix):lower() == prefix:lower() then
      items[#items + 1] = {
        word = snip.prefix,
        kind = "Snippet",
        menu = "[snip]",
        info = snip.description,
        user_data = { snippet_body = snip.body },
      }
    end
  end
  return items
end

-- Unified completion: LSP + snippets
local cancel_pending = nil

local function trigger_completion()
  if cancel_pending then
    cancel_pending()
    cancel_pending = nil
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local pos = vim.api.nvim_win_get_cursor(win)
  local lnum = pos[1] - 1
  local col = pos[2]
  local line = vim.api.nvim_get_current_line()
  local before = line:sub(1, col)
  local word = before:match("([%w_]+)$") or ""
  local startcol = col - #word + 1

  local ft = vim.bo[bufnr].filetype
  local snips = snippet_matches(ft, word)

  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/completion" })
  if #clients == 0 then
    if #snips > 0 then
      vim.fn.complete(startcol, apply_kind_icons(snips))
    end
    return
  end

  local client = clients[1]
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  params.context = { triggerKind = 1 }

  local ok, request_id = client:request("textDocument/completion", params, function(err, result)
    if err or not result then
      if #snips > 0 then
        vim.schedule(function()
          vim.fn.complete(startcol, snips)
        end)
      end
      return
    end

    vim.schedule(function()
      -- Use nvim's built-in converter
      local lsp_items = vim.lsp.completion._lsp_to_complete_items(
        result,
        word,
        client.id,
        startcol - 1,
        line,
        lnum,
        client.offset_encoding
      )
      vim.list_extend(lsp_items, snips)
      if #lsp_items > 0 then
        vim.fn.complete(startcol, apply_kind_icons(lsp_items))
      end
    end)
  end, bufnr)

  if ok and request_id then
    cancel_pending = function()
      client:cancel_request(request_id)
    end
  end
end

-- Debounced trigger on typing
local timer = vim.uv.new_timer()
vim.api.nvim_create_autocmd("TextChangedI", {
  callback = function()
    timer:stop()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
      return
    end
    local char = line:sub(col, col)
    if not char:match("[%w_%.:]") then
      return
    end
    timer:start(
      80,
      0,
      vim.schedule_wrap(function()
        if vim.fn.mode() == "i" then
          trigger_completion()
        end
      end)
    )
  end,
})

-- Expand snippet on CompleteDone (custom snippets + LSP snippet items)
vim.api.nvim_create_autocmd("CompleteDone", {
  callback = function()
    local item = vim.v.completed_item
    if not item or not item.user_data then
      return
    end
    local ud = item.user_data
    if type(ud) == "string" then
      local ok, parsed = pcall(vim.json.decode, ud)
      if ok then
        ud = parsed
      end
    end
    if type(ud) ~= "table" then
      return
    end

    local snippet_text
    if ud.snippet_body then
      -- Custom JSON snippet
      snippet_text = resolve_vscode_vars(ud.snippet_body)
    elseif ud.nvim and ud.nvim.lsp and ud.nvim.lsp.completion_item then
      -- LSP completion item with snippet insertTextFormat
      local ci = ud.nvim.lsp.completion_item
      if ci.insertTextFormat == 2 then
        snippet_text = ci.textEdit and ci.textEdit.newText or ci.insertText
      end
    end

    if not snippet_text then
      return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local prefix_len = #(item.word or "")
    local new_line = line:sub(1, col - prefix_len) .. line:sub(col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, col - prefix_len })
    vim.snippet.expand(snippet_text)
  end,
})

-- Try to expand a snippet trigger before cursor (for Tab expansion)
local function try_expand_trigger()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local before = line:sub(1, col)
  local word = before:match("([%w_]+)$")
  if not word then
    return false
  end
  local ft = vim.bo.filetype
  for _, snip in ipairs(get_snippets(ft)) do
    if snip.prefix == word then
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local new_line = line:sub(1, col - #word) .. line:sub(col + 1)
      vim.api.nvim_set_current_line(new_line)
      vim.api.nvim_win_set_cursor(0, { row, col - #word })
      vim.snippet.expand(resolve_vscode_vars(snip.body))
      return true
    end
  end
  return false
end

-- Tab: snippet jump > completion cycle > expand trigger > normal tab
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if vim.snippet.active({ direction = 1 }) then
    return "<Cmd>lua vim.snippet.jump(1)<CR>"
  elseif vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif try_expand_trigger() then
    return ""
  end
  return "<Tab>"
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if vim.snippet.active({ direction = -1 }) then
    return "<Cmd>lua vim.snippet.jump(-1)<CR>"
  elseif vim.fn.pumvisible() == 1 then
    return "<C-p>"
  end
  return "<S-Tab>"
end, { expr = true, silent = true })

-- Ghost text: show selected completion item as inline preview
local ghost_ns = vim.api.nvim_create_namespace("completion_ghost")

local function clear_ghost()
  vim.api.nvim_buf_clear_namespace(0, ghost_ns, 0, -1)
end

vim.api.nvim_create_autocmd("CompleteChanged", {
  callback = function()
    clear_ghost()
    local item = vim.v.event.completed_item
    if not item or not item.word or item.word == "" then
      return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(1, col)
    local prefix = before:match("([%w_]*)$") or ""
    local ghost = item.word:sub(#prefix + 1)
    if ghost == "" then
      return
    end

    vim.api.nvim_buf_set_extmark(0, ghost_ns, row - 1, col, {
      virt_text = { { ghost, "Comment" } },
      virt_text_pos = "overlay",
      hl_mode = "combine",
    })
  end,
})

vim.api.nvim_create_autocmd({ "CompleteDone", "InsertLeave" }, {
  callback = clear_ghost,
})
