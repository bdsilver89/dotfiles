local M = setmetatable({}, {
  __call = function(t, ...)
    return t.notify(...)
  end,
})

function M.notify(msg, opts)
  opts = opts or {}
  local notify = vim[opts.once and "notify_once" or "notify"]
  notify = vim.in_fast_event() and vim.schedule_wrap(notify) or notify
  msg = type(msg) == "table" and table.concat(msg, "\n") or msg
  msg = vim.trim(msg)
  opts.title = opts.title or "Config"
  return notify(msg, opts.level, opts)
end

function M.info(msg, opts)
  return M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.INFO }, opts or {}))
end

function M.warn(msg, opts)
  return M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.WARN }, opts or {}))
end

function M.error(msg, opts)
  return M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.ERROR }, opts or {}))
end

return M
