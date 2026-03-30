-- Minimal which-key replacement
-- Shows available keymaps in a popup after pressing <leader>

local groups = {
  [" b"] = "Buffer",
  [" g"] = "Git",
  [" h"] = "Hunk",
  [" q"] = "Session/Quit",
  [" u"] = "UI",
  [" x"] = "Diagnostics",
}

local ns = vim.api.nvim_create_namespace("whichkey")
local popup = {}

local function close()
  if popup.win and vim.api.nvim_win_is_valid(popup.win) then
    vim.api.nvim_win_close(popup.win, true)
  end
  if popup.buf and vim.api.nvim_buf_is_valid(popup.buf) then
    vim.api.nvim_buf_delete(popup.buf, { force = true })
  end
  popup.win, popup.buf = nil, nil
end

local function desc_of(m)
  if m.desc and m.desc ~= "" then
    return m.desc
  end
  local rhs = m.rhs or ""
  local cmd = rhs:match("<[Cc]md>(.-)<[Cc][Rr]>")
  if cmd then
    return ":" .. cmd
  end
  return rhs
end

local function build_title(prefix)
  local parts = { "Leader" }
  local path = prefix:sub(2)
  local cursor = " "
  for i = 1, #path do
    cursor = cursor .. path:sub(i, i)
    parts[#parts + 1] = groups[cursor] or path:sub(i, i)
  end
  return " " .. table.concat(parts, " > ") .. " "
end

local function show(prefix, children, exact)
  close()

  -- Build sorted entry list
  local by_key = {}
  local key_order = {}
  for lhs, m in pairs(children) do
    local key = lhs:sub(#prefix + 1, #prefix + 1)
    if not by_key[key] then
      by_key[key] = {}
      key_order[#key_order + 1] = key
    end
    by_key[key][#by_key[key] + 1] = { lhs = lhs, map = m }
  end
  table.sort(key_order)

  local entries = {}
  if exact then
    entries[#entries + 1] = { key = "<CR>", desc = desc_of(exact), is_group = false, hl = "Special" }
  end
  for _, key in ipairs(key_order) do
    local items = by_key[key]
    local dk = key == " " and "SPC" or key
    local is_group = not (#items == 1 and items[1].lhs == prefix .. key)
    local desc = is_group and (groups[prefix .. key] or "+group") or desc_of(items[1].map)
    entries[#entries + 1] = { key = dk, desc = desc, is_group = is_group, hl = "Function" }
  end

  if #entries == 0 then
    return
  end

  -- Measure columns
  local key_w = 0
  local desc_w = 0
  for _, e in ipairs(entries) do
    key_w = math.max(key_w, #e.key)
    desc_w = math.max(desc_w, vim.fn.strdisplaywidth(e.desc))
  end

  local cell_display_w = 1 + key_w + 2 + desc_w + 1 -- " key  desc "
  local sep_display_w = 3 -- " │ "
  local max_cols = math.max(1, math.floor((vim.o.columns - 6) / (cell_display_w + sep_display_w)))
  local num_cols = math.min(max_cols, math.ceil(#entries / 3))
  num_cols = math.max(1, num_cols)
  local num_rows = math.ceil(#entries / num_cols)

  -- Fill grid column-by-column
  local grid = {}
  for i, e in ipairs(entries) do
    local col = math.floor((i - 1) / num_rows) + 1
    local row = ((i - 1) % num_rows) + 1
    if not grid[row] then
      grid[row] = {}
    end
    grid[row][col] = e
  end

  -- Render lines and collect highlights using byte positions from the built string
  local lines = {}
  local hls = {}

  for row = 1, num_rows do
    local line = ""
    for col = 1, num_cols do
      if col > 1 then
        local sep_start = #line
        line = line .. " │ "
        hls[#hls + 1] = { row - 1, sep_start, #line, "FloatBorder" }
      end

      local e = grid[row] and grid[row][col]
      if e then
        local cell_start = #line
        local key_pad = string.rep(" ", key_w - #e.key)
        local desc_pad = string.rep(" ", desc_w - vim.fn.strdisplaywidth(e.desc))
        line = line .. " " .. e.key .. key_pad .. "  " .. e.desc .. desc_pad .. " "

        hls[#hls + 1] = { row - 1, cell_start + 1, cell_start + 1 + #e.key, e.hl }
        local desc_byte = cell_start + 1 + #e.key + #key_pad + 2
        hls[#hls + 1] = { row - 1, desc_byte, desc_byte + #e.desc, e.is_group and "Keyword" or "Comment" }
      else
        line = line .. string.rep(" ", cell_display_w)
      end
    end
    lines[#lines + 1] = line
  end

  popup.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(popup.buf, 0, -1, false, lines)
  vim.bo[popup.buf].modifiable = false

  for _, h in ipairs(hls) do
    vim.api.nvim_buf_add_highlight(popup.buf, ns, h[4], h[1], h[2], h[3])
  end

  local total_w = vim.fn.strdisplaywidth(lines[1] or "")
  local title = build_title(prefix)

  popup.win = vim.api.nvim_open_win(popup.buf, false, {
    relative = "editor",
    anchor = "SE",
    row = vim.o.lines - 3,
    col = vim.o.columns - 1,
    width = total_w,
    height = num_rows,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
    noautocmd = true,
    focusable = false,
  })
end

local function exec(m)
  if m.callback then
    m.callback()
  elseif m.rhs and m.rhs ~= "" then
    local rhs = vim.api.nvim_replace_termcodes(m.rhs, true, true, true)
    vim.api.nvim_feedkeys(rhs, (m.noremap and m.noremap ~= 0) and "n" or "m", false)
  end
end

local function start()
  local keys = " " -- resolved leader (space)

  -- Snapshot all normal-mode mappings
  local all = {}
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
    all[m.lhs] = m
  end
  for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
    if not all[m.lhs] then
      all[m.lhs] = m
    end
  end

  local function get_children()
    local c = {}
    for lhs, m in pairs(all) do
      if lhs:sub(1, #keys) == keys and #lhs > #keys and (m.desc or "") ~= "WhichKey" then
        c[lhs] = m
      end
    end
    return c
  end

  local function get_exact()
    local m = all[keys]
    return (m and (m.desc or "") ~= "WhichKey") and m or nil
  end

  -- Show popup after timeoutlen
  local timer = vim.uv.new_timer()
  timer:start(vim.o.timeoutlen, 0, vim.schedule_wrap(function()
    local c = get_children()
    if not vim.tbl_isempty(c) then
      show(keys, c, get_exact())
      vim.cmd.redraw()
    end
  end))

  while true do
    local ok, char = pcall(vim.fn.getcharstr)
    timer:stop()

    if not ok or char == "\27" then
      close()
      return
    end

    local key_name = vim.fn.keytrans(char)

    -- Enter executes the exact match at current prefix
    if key_name == "<CR>" then
      local e = get_exact()
      if e then
        close()
        exec(e)
        return
      end
      goto continue
    end

    -- Backspace goes up one level
    if key_name == "<BS>" then
      if #keys > 1 then
        keys = keys:sub(1, -2)
        show(keys, get_children(), get_exact())
        vim.cmd.redraw()
      else
        close()
        return
      end
      goto continue
    end

    keys = keys .. char

    local e = get_exact()
    local c = get_children()
    local has_c = not vim.tbl_isempty(c)

    if e and not has_c then
      -- Unique match, execute immediately
      close()
      exec(e)
      return
    elseif not e and not has_c then
      -- No match, abort
      close()
      return
    else
      -- More keys needed, show popup
      show(keys, c, e)
      vim.cmd.redraw()
    end

    ::continue::
  end
end

vim.keymap.set("n", "<leader>", function()
  start()
end, { nowait = true, desc = "WhichKey" })
