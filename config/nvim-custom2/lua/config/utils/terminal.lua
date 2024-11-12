local M = setmetatable({}, {
  __call = function(t, ...)
    return t.open(...)
  end,
})

local defaults = {
  win = {
    -- style = "terminal",
  },
}

local styles = {
  terminal = {
    bo = {},
    wo = {},
    keys = {},
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

function M.toggle(cmd, opts)
  opts = opts or {}

  local id = vim.inspect({ cmd = cmd, cwd = opts.cwd, env = opts.env, count = vim.v.count1 })

  if terminals[id] and terminals[id]:buf_valid() then
    terminals[id]:toggle()
  else
    terminals[id] = M.open(cmd, opts)
  end
  return terminals[id]
end

return M
