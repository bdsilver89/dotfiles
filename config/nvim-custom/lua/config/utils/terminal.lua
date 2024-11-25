local Notify = require("config.utils.notify")

local M = setmetatable({}, {
  __call = function(t, ...)
    return t.toggle(...)
  end,
})

local defaults = {
  win = {
    -- style = "terminal",
  },
}

local function term_nav(dir)
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

local styles = {
  terminal = {
    bo = {},
    wo = {},
    keys = {
      gf = function(self)
        local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
        if f == "" then
          Notify.warn("No file under cursor", { title = "Config" })
        else
          self:hide()
          vim.schedule(function()
            vim.cmd("e " .. f)
          end)
        end
      end,
      term_normal = {
        "<esc>",
        function(self)
          self.esc_timer = self.esc_timer or vim.uv.new_timer()
          if self.esc_timer:is_active() then
            self.esc_timer:stop()
            vim.cmd("stopinsert")
          else
            self.esc_timer:start(200, 0, function() end)
            return "<esc>"
          end
        end,
        mode = "t",
        expr = true,
        desc = "Double escape to normal mode",
      },
      nav_h = { "<c-h>", term_nav("h"), desc = "Go to left window", expr = true, mode = "t" },
      nav_j = { "<c-j>", term_nav("j"), desc = "Go to lower window", expr = true, mode = "t" },
      nav_k = { "<c-k>", term_nav("k"), desc = "Go to upper window", expr = true, mode = "t" },
      nav_l = { "<c-l>", term_nav("l"), desc = "Go to right window", expr = true, mode = "t" },
    },
  },
}

local terminals = {}

function M.open(cmd, opts)
  local id = vim.v.count1
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  opts.win = vim.tbl_deep_extend("force", styles.terminal, { position = cmd and "float" or "bottom" }, opts.win or {})
  opts.win.wo.winbar = opts.win.wo.winbar or (opts.win.position == "float" and "" or (id .. ": %{b:term_title}"))

  if opts.override then
    return opts.override(cmd, opts)
  end

  local on_buf = opts.win and opts.win.on_buf

  opts.win.on_buf = function(self)
    self.cmd = cmd
    vim.b[self.buf].config_terminal = { cmd = cmd, id = id }
    if on_buf then
      on_buf(self)
    end
  end

  local terminal = require("config.utils.win")(opts.win)

  vim.api.nvim_buf_call(terminal.buf, function()
    local term_opts = {
      cwd = opts.cwd,
      env = opts.env,
    }
    vim.fn.termopen(cmd or { vim.o.shell }, vim.tbl_isempty(term_opts) and vim.empty_dict() or term_opts)
  end)

  if opts.interactive ~= false then
    vim.cmd.startinsert()
    vim.api.nvim_create_autocmd("TermClose", {
      once = true,
      buffer = terminal.buf,
      callback = function()
        if type(vim.v.event) == "table" and vim.v.event.status ~= 0 then
          Notify.error(
            "Terminal exited with code " .. vim.v.event.status .. ".\nCheck for any errors.",
            { title = "Terminal" }
          )
          return
        end
        terminal:close()
        vim.cmd.checktime()
      end,
    })
    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = terminal.buf,
      callback = function()
        vim.cmd.startinsert()
      end,
    })
  end

  vim.cmd("noh")
  return terminal
end

function M.get(cmd, opts)
  opts = opts or {}

  local id = vim.inspect({ cmd = cmd, cwd = opts.cwd, env = opts.env, count = vim.v.count1 })
  local created = false
  if not (terminals[id] and terminals[id]:buf_valid()) and (opts.create ~= false) then
    terminals[id] = M.open(cmd)
    created = true
  end
  return terminals[id], created
end

function M.toggle(cmd, opts)
  local terminal, created = M.get(cmd, opts)
  return created and terminal or assert(terminal):toggle()
end

function M.parse(cmd)
  local args = {}
  local in_quotes, escape_next, current = false, false, ""
  local function add()
    if #current > 0 then
      table.insert(args, current)
      current = ""
    end
  end

  for i = 1, #cmd do
    local char = cmd:sub(i, i)
    if escape_next then
      current = current .. ((char == '"' or char == "\\") and "" or "\\") .. char
      escape_next = false
    elseif char == "\\" and in_quotes then
      escape_next = true
    elseif char == '"' then
      in_quotes = not in_quotes
    elseif char:find("[ \t]") and not in_quotes then
      add()
    else
      current = current .. char
    end
  end
  add()
  return args
end

function M.colorize()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.statuscolumn = false
  vim.wo.signcolumn = "no"
  vim.opt.listchars = { space = " " }

  local buf = vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  while #lines > 0 and vim.trim(lines[#lines]) == "" do
    lines[#lines] = nil
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  vim.api.nvim_chan_send(vim.api.nvim_open_term(buf, {}), table.concat(lines, "\r\n"))
  vim.keymap.set("n", "q", "<cmd>q<cr>", { silent = true, buffer = buf })
  vim.api.nvim_create_autocmd("TextChanged", {
    buffer = buf,
    callback = function()
      pcall(vim.api.nvim_win_set_cursor, 0, { #lines, 0 })
    end,
  })
  vim.api.nvim_create_autocmd("TermEnter", { buffer = buf, command = "stopinsert" })
end

return M
