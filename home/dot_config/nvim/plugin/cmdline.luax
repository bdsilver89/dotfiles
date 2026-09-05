local config = {
  width = { value = "60%", min = 40, max = 80 },
  row = "35%",
  border = "rounded",
}

local function parse(value, available)
  if type(value) == "string" then
    return math.floor(available * tonumber(value:match("^(%d+)%%$")) / 100)
  end
  return math.floor(value)
end

---@return integer width, integer row, integer col
local function geometry()
  local cols = vim.o.columns
  local width = math.max(config.width.min, math.min(config.width.max, parse(config.width.value, cols)))
  width = math.min(width, cols - 4)
  return width, parse(config.row, vim.o.lines), math.max(0, math.floor((cols - width - 2) / 2))
end

local saved = nil ---@type table|nil

local function set_cmdheight_0()
  vim._with({ noautocmd = true, o = { splitkeep = "screen" } }, function()
    vim.o.cmdheight = 0
  end)
end

local ui2 = require("vim._core.ui2")
local ui2_cmd = require("vim._core.ui2.cmdline")

local function get_cmd_win()
  local win = ui2.wins and ui2.wins.cmd
  return (win and vim.api.nvim_win_is_valid(win)) and win or nil
end

local function reposition()
  local win = vim.fn.getcmdtype() ~= "" and get_cmd_win()
  if not win then
    return
  end

  local current = vim.api.nvim_win_get_config(win)

  if not saved then
    saved = {
      relative = current.relative,
      anchor = current.anchor,
      col = current.col,
      row = current.row,
      width = current.width,
      border = current.border or "none",
    }
    vim.wo[win].winhighlight = "Normal:CmdlineNormal,FloatBorder:CmdlineBorder"
  end

  local width, row, col = geometry()

  if
    current.relative ~= "editor"
    or current.row ~= row
    or current.col ~= col
    or current.width ~= width
  then
    pcall(vim.api.nvim_win_set_config, win, {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      border = config.border,
    })
  end

  -- Read by blink.cmp's completion.menu.cmdline_position to place the wildmenu:
  -- one row under the bottom border, and past the border + prompt char.
  vim.g.ui_cmdline_pos = { row + vim.api.nvim_win_get_height(win) + 2, col + 2 }
end

local orig_show = ui2_cmd.cmdline_show
ui2_cmd.cmdline_show = function(...)
  local r = orig_show(...)
  -- nvim's win_config() forces cmdheight to the cmdline text height on every
  -- show; the float makes that row dead space, so claw it back each time.
  set_cmdheight_0()
  reposition()
  return r
end

vim.api.nvim_set_hl(0, "CmdlineNormal", { link = "NormalFloat", default = true })
vim.api.nvim_set_hl(0, "CmdlineBorder", { link = "FloatBorder", default = true })

local group = vim.api.nvim_create_augroup("config_cmdline", { clear = true })

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = group,
  callback = function()
    vim.g.ui_cmdline_pos = nil

    local win = get_cmd_win()
    if win and saved then
      pcall(vim.api.nvim_win_set_config, win, saved)
      vim.wo[win].winhighlight = ""
    end
    saved = nil
    vim.schedule(set_cmdheight_0)
  end,
})

vim.api.nvim_create_autocmd({ "VimResized", "TabEnter" }, {
  group = group,
  callback = function()
    vim.schedule(reposition)
  end,
})
