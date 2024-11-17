local Notify = require("config.utils.notify")

local M = setmetatable({}, {
  __call = function(t, ...)
    return t.new(...)
  end,
})

local defaults = {
  show = true,
  relative = "editor",
  position = "float",
  minimal = true,
  wo = {},
  bo = {},
  keys = {
    q = "close",
  },
}

local styles = {
  float = {
    position = "float",
    height = 0.9,
    width = 0.9,
    zindex = 50,
  },
  split = {
    position = "bottom",
    height = 0.4,
    width = 0.4,
  },
  minimal = {
    wo = {
      cursorcolumn = false,
      cursorline = false,
      cursorlineopt = "both",
      fillchars = "eob: ,lastline:…",
      list = false,
      listchars = "extends:…,tab:  ",
      number = false,
      relativenumber = false,
      signcolumn = "no",
      spell = false,
      winbar = "",
      statuscolumn = "",
      wrap = false,
      sidescrolloff = 0,
    },
  },
}

local split_commands = {
  editor = {
    top = "topleft",
    right = "vertical botright",
    bottom = "botright",
    left = "vertical topleft",
  },
  win = {
    top = "aboveleft",
    right = "vertical rightbelow",
    bottom = "belowright",
    left = "vertical leftabove",
  },
}

local win_opts = {
  "anchor",
  "border",
  "bufpos",
  "col",
  "external",
  "fixed",
  "focusable",
  "footer",
  "footer_pos",
  "height",
  "hide",
  "noautocmd",
  "relative",
  "row",
  "style",
  "title",
  "title_pos",
  "width",
  "win",
  "zindex",
}

local id = 0

function M.new(opts)
  local self = setmetatable({}, { __index = M })
  id = id + 1
  self.id = id

  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  if opts.minimal then
    opts = vim.tbl_deep_extend("force", styles.minimal, opts)
  end
  if opts.position == "float" then
    opts = vim.tbl_deep_extend("force", styles.float, opts)
  else
    opts = vim.tbl_deep_extend("force", styles.split, opts)
    local vertical = opts.position == "left" or opts.position == "right"
    opts.wo.winfixheight = not vertical
    opts.wo.winfixwidth = vertical
  end

  self.opts = opts
  if opts.show ~= false then
    self:show()
  end
  return self
end

function M:focus()
  if self:valid() then
    vim.api.nvim_set_current_win(self.win)
  end
end

function M:close(opts)
  opts = opts or {}
  local wipe = opts.buf ~= false and not self.opts.buf and not self.opts.file

  local win = self.win
  local buf = wipe and self.buf
  self.win = nil
  if buf then
    self.buf = nil
  end

  vim.schedule(function()
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    if self.augroup then
      pcall(vim.api.nvim_del_augroup_by_id, self.augroup)
      self.augroup = nil
    end
  end)
end

function M:hide()
  self:close({ buf = false })
end

function M:toggle()
  if self:valid() then
    self:hide()
  else
    self:show()
  end
end

---@private
function M:open_buf()
  if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
    self.buf = self.buf

  -- TODO: elseif self.opts.file then
  elseif self.opts.buf then
    self.buf = self.opts.buf
  else
    self.buf = vim.api.nvim_create_buf(false, true)
  end

  if vim.bo[self.buf].filetype == "" and not self.opts.bo.filetype then
    self.opts.bo.filetype = "config_win"
  end
  return self.buf
end

---@private
function M:open_win()
  local relative = self.opts.relative or "editor"
  local position = self.opts.position or "float"
  local enter = self.opts.enter == nil or self.opts.enter or false
  local opts = self:win_opts()
  if position == "float" then
    self.win = vim.api.nvim_open_win(self.buf, enter, opts)
  else
    local parent = self.opts.win or 0
    local vertical = position == "left" or position == "right"
    if parent == 0 then
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if
          vim.w[win].config_win
          and vim.w[win].config_win.relative == relative
          and vim.w[win].config_win.position == position
        then
          parent = win
          relative = "win"
          position = vertical and "bottom" or "right"
          vertical = not vertical
          break
        end
      end
    end
    local cmd = split_commands[relative][position]
    local size = vertical and opts.width or opts.height
    vim.api.nvim_win_call(parent, function()
      vim.cmd("silent noswapfile " .. cmd .. " " .. size .. "split")
      vim.api.nvim_win_set_buf(0, self.buf)
      self.win = vim.api.nvim_get_current_win()
    end)
    if enter then
      vim.api.nvim_set_current_win(self.win)
    end
    vim.schedule(function()
      self:equalize()
    end)
  end
  vim.w[self.win].config_win = {
    id = self.id,
    position = self.opts.position,
    relative = self.opts.relative,
  }
end

function M:equalize()
  if self:is_floating() then
    return
  end
  local all = vim.tbl_filter(function(win)
    return vim.w[win].config_win
      and vim.w[win].config_win.relative == self.opts.relative
      and vim.w[win].config_win.position == self.opts.position
  end, vim.api.nvim_list_wins())
  if #all <= 1 then
    return
  end
  local vertical = self.opts.position == "left" or self.opts.position == "right"
  local parent_size = self:parent_size()[vertical and "height" or "width"]
  local size = math.floor(parent_size / #all)
  for _, win in ipairs(all) do
    vim.api.nvim_win_call(win, function()
      vim.cmd(("%s resize %s"):format(vertical and "horizontal" or "vertical", size))
    end)
  end
end

function M:update()
  if self:valid() then
    self:set_options("buf")
    self:set_options("win")
    if self:is_floating() then
      local opts = self:win_opts()
      opts.noautocmd = nil
      vim.api.nvim_win_set_config(self.win, opts)
    end
  end
end

function M:show()
  if self:valid() then
    self:update()
    return self
  end
  self.augroup = vim.api.nvim_create_augroup("config_win_" .. self.id, { clear = true })

  self:open_buf()

  local optim_hl = not vim.b[self.buf].ts_highlight and vim.bo[self.buf].syntax == ""
  vim.b[self.buf].ts_highlight = optim_hl or vim.b[self.buf].ts_highlight
  self:set_options("buf")
  vim.b[self.buf].ts_highlight = not optim_hl and vim.b[self.buf].ts_highlight or nil

  if self.opts.on_buf then
    self.opts.on_buf(self)
  end

  self:open_win()
  self:set_options("win")
  if self.opts.on_win then
    self.opts.on_win(self)
  end

  -- FIX: this doesn't work...
  -- local ft = self.opts.ft or vim.bo[self.buf].filetype
  -- if ft and not vim.b[self.buf].ts_highlight and vim.bo[self.buf].syntax == "" then
  --   local lang = vim.treesitter.get_lang(ft)
  --   if not (lang and pcall(vim.treesitter.start, self.buf, lang)) then
  --     vim.bo[self.buf].syntax = ft
  --   end
  -- end

  vim.api.nvim_create_autocmd("VimResized", {
    group = self.augroup,
    callback = function()
      self:update()
    end,
  })

  for key, spec in pairs(self.opts.keys) do
    if spec then
      if type(spec) == "string" then
        spec = { key, self[spec] or spec, desc = spec }
      elseif type(spec) == "function" then
        spec = { key, spec }
      end
      local opts = vim.deepcopy(spec)
      opts[1] = nil
      opts[2] = nil
      opts.mode = nil
      opts.buffer = self.buf
      local rhs = spec[2]
      if type(rhs) == "function" then
        rhs = function()
          return spec[2](self)
        end
      end
      vim.keymap.set(spec.mode or "n", spec[1], rhs, opts)
    end
  end

  -- self:drop()

  return self
end

function M:add_padding()
  self.opts.wo.statuscolumn = " "
  self.opts.wo.list = true
  self.opts.wo.listchars = ("eol: ," .. (self.opts.wo.listchars or "")):gsub(",$", "")
end

function M:is_floating()
  return self:valid() and vim.api.nvim_win_get_config(self.win).zindex ~= nil
end

---@param from? number
---@param to? number
function M:lines(from, to)
  return self:buf_valid() and vim.api.nvim_buf_get_lines(self.buf, from or 0, to or -1, false) or {}
end

---@param from? number
---@param to? number
function M:text(from, to)
  return table.concat(self:lines(from, to), "\n")
end

function M:parent_size()
  return {
    height = self.opts.relative == "win" and vim.api.nvim_win_get_height(self.opts.win) or vim.o.lines,
    width = self.opts.relative == "win" and vim.api.nvim_win_get_width(self.opts.win) or vim.o.columns,
  }
end

---@private
function M:win_opts()
  local opts = {}
  for _, k in ipairs(win_opts) do
    opts[k] = self.opts[k]
  end
  local parent = self:parent_size()
  opts.height = opts.height == 0 and parent.height or opts.height
  opts.width = opts.width == 0 and parent.width or opts.width
  opts.height = math.floor(opts.height < 1 and parent.height * opts.height or opts.height)
  opts.width = math.floor(opts.width < 1 and parent.width * opts.width or opts.width)

  if opts.relative == "cursor" then
    return opts
  end
  opts.row = opts.row or math.floor((parent.height - opts.height) / 2)
  opts.col = opts.col or math.floor((parent.width - opts.width) / 2)
  return opts
end

function M:size()
  local opts = self:win_opts()
  local height = opts.height
  local width = opts.width
  if self:has_border() then
    height = height + 2
    width = width + 2
  end
  return { height = height, width = width }
end

function M:has_border()
  return self.opts.border and self.opts.border ~= "" and self.opts.border ~= "none"
end

function M:border_text_width()
  if not self:has_border() then
    return 0
  end

  local ret = 0
  for _, t in ipairs({ "title", "footer" }) do
    local str = self.opts[t] or {}
    str = type(str) == "string" and { str } or str
    ret = math.max(ret, #table.concat(
      vim.tbl_map(function(s)
        return type(s) == "string" and s or s[1]
      end, str),
      ""
    ))
  end
  return ret
end

---@private
---@param type "win"|"buf"
function M:set_options(type)
  local opts = type == "win" and self.opts.wo or self.opts.bo
  for k, v in pairs(opts or {}) do
    local ok, err = pcall(vim.api.nvim_set_option_value, k, v, type == "win" and {
      scope = "local",
      win = self.win,
    } or { buf = self.buf })
    if not ok then
      Notify.error(
        "Error setting option `" .. tostring(k) .. "=" .. tostring(v) .. "`\n\n" .. err,
        { title = "Window" }
      )
    end
  end
end

function M:buf_valid()
  return self.buf and vim.api.nvim_buf_is_valid(self.buf)
end

function M:win_valid()
  return self.win and vim.api.nvim_win_is_valid(self.win)
end

function M:valid()
  return self:win_valid() and self:buf_valid() and vim.api.nvim_win_get_buf(self.win) == self.buf
end

return M
