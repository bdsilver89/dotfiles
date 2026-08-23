local kind_icons = require("icons").symbol_kinds
local folder_icon = kind_icons.Folder

local M = {}

---@type table<integer, {icon: string, name: string}[]> window -> cached breadcrumb chain
local symbol_cache = {}
---@type table<integer, uv.uv_timer_t> buffer -> debounce timer
local symbol_timers = {}

---@param symbols table[] DocumentSymbol[] (nested) or SymbolInformation[] (flat)
---@param row integer 0-indexed cursor line
---@param col integer 0-indexed cursor col
---@return table[] chain outermost..innermost containing symbol
local function containing_chain(symbols, row, col)
  local chain = {}

  ---@param range table
  local function contains(range)
    local s, e = range.start, range["end"]
    if row < s.line or row > e.line then
      return false
    end
    if row == s.line and col < s.character then
      return false
    end
    if row == e.line and col > e.character then
      return false
    end
    return true
  end

  local function walk(list)
    for _, sym in ipairs(list) do
      -- DocumentSymbol has `range`; SymbolInformation has `location.range`
      local range = sym.range or (sym.location and sym.location.range)
      if range and contains(range) then
        table.insert(chain, sym)
        if sym.children then
          walk(sym.children)
        end
        break
      end
    end
  end

  walk(symbols)
  return chain
end

---@param bufnr integer
---@param winid integer
local function request_symbols(bufnr, winid)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/documentSymbol" })
  if #clients == 0 then
    symbol_cache[winid] = nil
    return
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  clients[1]:request("textDocument/documentSymbol", params, function(err, result)
    if err or not result or not vim.api.nvim_win_is_valid(winid) then
      return
    end
    if vim.api.nvim_win_get_buf(winid) ~= bufnr then
      return
    end

    local cursor = vim.api.nvim_win_get_cursor(winid)
    local row, col = cursor[1] - 1, cursor[2]
    local chain = containing_chain(result, row, col)

    symbol_cache[winid] = #chain > 0
        and vim
          .iter(chain)
          :map(function(sym)
            local kind = vim.lsp.protocol.SymbolKind[sym.kind] or "Field"
            return { icon = kind_icons[kind] or "", name = sym.name }
          end)
          :totable()
      or nil
    vim.cmd.redrawstatus()
  end, bufnr)
end

function M.render()
  local path = vim.fs.normalize(vim.fn.expand("%:p"))
  if vim.startswith(path, "diffview") then
    return string.format("%%#Winbar#%s", path)
  end

  local separator = " %#WinbarSeparator# "
  local prefix, prefix_path = "", ""

  if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
    path = vim.fn.pathshorten(path)
  else
    local special_dirs = {
      HOME = vim.env.HOME,
      DOTFILES = vim.env.HOME .. "/dotfiles",
    }
    if vim.fn.isdirectory(vim.env.HOME .. "/Developer/projects") then
      special_dirs["PROJECTS"] = vim.env.HOME .. "/Developer/projects"
    else
      special_dirs["PROJECTS"] = vim.env.HOME .. "/dev/projects"
    end

    for dir_name, dir_path in pairs(special_dirs) do
      if vim.startswith(path, vim.fs.normalize(dir_path)) and #dir_path > #prefix_path then
        prefix = dir_name
        prefix_path = dir_path
      end
    end
    if prefix ~= "" then
      path = path:gsub("^" .. vim.pesc(prefix_path), "")
      prefix = string.format("%%#WinBarDir#%s %s%s", folder_icon, prefix, separator)
    end
  end

  path = path:gsub("^/", "")

  local chain = symbol_cache[vim.api.nvim_get_current_win()]
  local breadcrumb = ""
  if chain then
    breadcrumb = separator
      .. table.concat(
        vim
          .iter(chain)
          :map(function(sym)
            local prefix_icon = sym.icon ~= "" and (sym.icon .. " ") or ""
            return string.format("%%#Winbar#%s%s", prefix_icon, sym.name)
          end)
          :totable(),
        separator
      )
  end

  return table.concat({
    " ",
    prefix,
    table.concat(
      vim
        .iter(vim.split(path, "/"))
        :map(function(segment)
          return string.format("%%#Winbar#%s", segment)
        end)
        :totable(),
      separator
    ),
    breadcrumb,
  })
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("winbar", { clear = true }),
  callback = function(ev)
    if
      not vim.api.nvim_win_get_config(0).zindex
      and vim.bo[ev.buf].buftype == ""
      and vim.api.nvim_buf_get_name(ev.buf) ~= ""
      and not vim.wo[0].diff
    then
      vim.wo.winbar = "%{%v:lua.require'winbar'.render()%}"
    end
  end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("winbar_symbols", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local winid = vim.api.nvim_get_current_win()

    if symbol_timers[ev.buf] then
      symbol_timers[ev.buf]:stop()
    end
    symbol_timers[ev.buf] = vim.defer_fn(function()
      request_symbols(ev.buf, winid)
    end, 150)
  end,
})

vim.api.nvim_create_autocmd("WinClosed", {
  group = "winbar_symbols",
  callback = function(ev)
    symbol_cache[tonumber(ev.match)] = nil
  end,
})

return M
