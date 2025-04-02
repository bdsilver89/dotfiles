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

-- LSP progress display
local icons = {
  spinner = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
  done = " ",
}
local clients = {}
local total_wins = 0

local function guard(callable)
  local whitelist = {
    "E11: Invalid in command%-line window",
    "E523: Not allowed here",
    "E565: Not allowed to change",
  }
  local ok, err = pcall(callable)
  if ok then
    return true
  end
  if type(err) ~= "string" then
    error(err)
  end
  for _, msg in ipairs(whitelist) do
    if string.find(err, msg) then
      return false
    end
  end
  error(err)
end

local function init_or_reset(client)
  client.is_done = false
  client.spinner_idx = 0
  client.winid = nil
  client.bufnr = nil
  client.message = nil
  client.pos = total_wins + 1
  client.timer = nil
end

local function get_win_row(pos)
  return vim.o.lines - vim.o.cmdheight - 1 - pos * 3
end

local function win_update_config(client)
  vim.api.nvim_win_set_config(client.winid, {
    relative = "editor",
    width = #client.message,
    height = 1,
    row = get_win_row(client.pos),
    col = vim.o.columns - #client.message,
  })
end

local function close_window(winid, bufnr)
  if vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

local function process_message(client, name, params)
  local message = ""
  message = "[" .. name .. "]"
  local kind = params.value.kind
  local title = params.value.title
  if title then
    message = message .. " " .. title .. ":"
  end
  if kind == "end" then
    client.is_done = true
    message = icons.done .. " " .. message .. " DONE!"
  else
    client.is_done = false
    local raw_msg = params.value.message
    local pct = params.value.percentage
    if raw_msg then
      message = message .. " " .. raw_msg
    end
    if pct then
      message = string.format("%s (%3d%%)", message, pct)
    end
    -- Spinner
    local idx = client.spinner_idx
    idx = idx == #icons.spinner * 4 and 1 or idx + 1
    message = icons.spinner[math.ceil(idx / 4)] .. " " .. message
    client.spinner_idx = idx
  end
  return message
end

local function show_message(client)
  local winid = client.winid
  if
    winid == nil
    or not vim.api.nvim_win_is_valid(winid)
    or vim.api.nvim_win_get_tabpage(winid) ~= vim.api.nvim_get_current_tabpage() -- Switch to another tab
  then
    local success = guard(function()
      winid = vim.api.nvim_open_win(client.bufnr, false, {
        relative = "editor",
        width = #client.message,
        height = 1,
        row = get_win_row(client.pos),
        col = vim.o.columns - #client.message,
        focusable = false,
        style = "minimal",
        noautocmd = true,
        border = vim.g.border_style,
      })
    end)
    if not success then
      return
    end
    client.winid = winid
    total_wins = total_wins + 1
  else
    win_update_config(client)
  end
  vim.wo[winid].winhl = "Normal:Normal"
  guard(function()
    vim.api.nvim_buf_set_lines(client.bufnr, 0, 1, false, { client.message })
  end)
end

local group = vim.api.nvim_create_augroup("config_lspprogress", { clear = true })
vim.api.nvim_create_autocmd({ "LspProgress" }, {
  group = group,
  pattern = "*",
  callback = function(args)
    local client_id = args.data.client_id
    if clients[client_id] == nil then
      clients[client_id] = {}
      init_or_reset(clients[client_id])
    end
    local cur_client = clients[client_id]

    if cur_client.bufnr == nil then
      cur_client.bufnr = vim.api.nvim_create_buf(false, true)
    end
    if cur_client.timer == nil then
      cur_client.timer = vim.uv.new_timer()
    end

    cur_client.message = process_message(cur_client, vim.lsp.get_client_by_id(client_id).name, args.data.params)

    show_message(cur_client)

    if cur_client.is_done then
      cur_client.timer:start(
        2000,
        100,
        vim.schedule_wrap(function()
          if not cur_client.is_done and cur_client.winid ~= nil then
            cur_client.timer:stop()
            return
          end
          local success = false
          if cur_client.winid ~= nil and cur_client.bufnr ~= nil then
            success = guard(function()
              close_window(cur_client.winid, cur_client.bufnr)
            end)
          end
          if success then
            cur_client.timer:stop()
            cur_client.timer:close()
            total_wins = total_wins - 1
            for _, c in pairs(clients) do
              if c.winid ~= nil and c.pos > cur_client.pos then
                c.pos = c.pos - 1
                win_update_config(c)
              end
            end
            init_or_reset(cur_client)
          end
        end)
      )
    end
  end,
})

vim.api.nvim_create_autocmd({ "VimResized", "TermLeave" }, {
  group = group,
  pattern = "*",
  callback = function()
    for _, c in ipairs(clients) do
      if c.is_done then
        win_update_config(c)
      end
    end
  end,
})
