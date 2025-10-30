local M = {}

function M.progress_bar(opts)
  opts = vim.tbl_deep_extend("force", {
    icon = {
      on = "-",
      off = "-",
    },
    hl = {
      on = "exred",
      off = "linenr",
    },
  }, opts or {})

  local activelen = math.floor(opts.w * (opts.val / 100))
  local inactivelen = opts.w - activelen

  return {
    { string.rep(opts.icon.on, activelen), opts.hl.on },
    { string.rep(opts.icon.off, inactivelen), opts.hl.off },
  }
end

function M.separator(char, w, hl)
  return { { string.rep(char or "─", w), hl or "linenr" } }
end

return M
