local M = {}

---@type table<string, table<integer, table>>
M.user_terminals = {}

---@param path string
function M.system_open(path)
  local cmd
  if vim.fn.has("mac") == 1 then
    cmd = { "open" }
  elseif vim.fn.has("win32") == 1 then
    if vim.fn.executable("rundll32") then
      cmd = { "rundll32", "/K", "explorer" }
    else
      cmd = { "cmd.exe", "/K", "explorer" }
    end
  elseif vim.fn.has("unix") == 1 then
    if vim.fn.executable("explorer.exe") == 1 then
      -- WSL!
      cmd = { "explorer.exe" }
    else
      cmd = { "xdg-open" }
    end
  end
  if not cmd then
    require("utils").log.error("Available system opening tool not found!")
  end
  if not path then
    path = vim.fn.expand("<cfile>")
  elseif not path:match("%w+") then
    path = vim.fn.expand(path)
  end
  vim.fn.jobstart(vim.list_extend(cmd, { path }), { detach = true })
end

---@param opts string|table
function M.cmd(opts)
  local terms = M.user_terminals
  if type(opts) == "string" then
    opts = { cmd = opts }
  end
  opts = vim.tbl_deep_extend("force", { hidden = true }, opts)
  local num = vim.v.count > 0 and vim.v.count or 1
  -- if terminal doesn't exist yet, create it
  if not terms[opts.cmd] then
    terms[opts.cmd] = {}
  end
  if not terms[opts.cmd][num] then
    if not opts.count then
      opts.count = vim.tbl_count(terms) * 100 + num
    end
    local on_exit = opts.on_exit
    opts.on_exit = function(...)
      terms[opts.cmd][num] = nil
      if on_exit then
        on_exit(...)
      end
    end
    terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
  end
  -- toggle the terminal
  terms[opts.cmd][num]:toggle()
end

return M
