-- Custom JSON snippet loader + Tab expansion
-- LSP completion: vim.lsp.completion.enable() in lsp.lua
-- Path completion: <C-x><C-f> (built-in)
-- Buffer words: <C-n>/<C-p> (built-in)

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
    vim.snippet.jump(1)
  elseif vim.fn.pumvisible() == 1 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
  elseif not try_expand_trigger() then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
  elseif vim.fn.pumvisible() == 1 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
  end
end, { silent = true })
