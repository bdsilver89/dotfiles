local M = {}

local function pattern_match(str, pattern_list)
  for _, pattern in ipairs(pattern_list) do
    if str:find(pattern) then
      return true
    end
  end
  return false
end

local buf_matchers = {
  filetype = function(pattern_list, bufnr)
    return pattern_match(vim.bo[bufnr or 0].filetype, pattern_list)
  end,
  buftype = function(pattern_list, bufnr)
    return pattern_match(vim.bo[bufnr or 0].buftype, pattern_list)
  end,
  bufname = function(pattern_list, bufnr)
    return pattern_match(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr or 0), ":t"), pattern_list)
  end,
}

local function buffer_matches(patterns, bufnr)
  for kind, pattern_list in ipairs(patterns) do
    if buf_matchers[kind](pattern_list, bufnr) then
      return true
    end
  end
  return false
end

function M.padding()
  local winid = vim.api.nvim_tabpage_list_wins(0)[1]
  local match = buffer_matches({
    filetype = {
      "NvimTree",
      "OverseerList",
      "aerial",
      "dap-repl",
      "dapui_.",
      "edgy",
      "neo%-tree",
      "undotree",
    },
  }, vim.api.nvim_win_get_buf(winid))

  if match then
    return string.rep(" ", vim.api.nvim_win_get_width(winid) + 1)
  else
    return ""
  end
end

function M.cwd()
  local uis = vim.api.nvim_list_uis()
  local ui = uis[1] or { width = 80 }

  -- local extraparts = {
  --   --2 + 1, -- search symbol
  --   --2 + self.search_contents:len(), -- term padding
  --   2 + 5, -- counts
  --   8, -- icon and root text
  --   2 + 1, -- branch indicator
  --   self.branch:len(), -- branch
  --   2 + 7, -- clipboard indicator
  --   2 + 1, -- remote indicator
  -- }
  local extrachars = 0
  -- for _, len in pairs(extraparts) do
  --   extrachars = extrachars + len
  -- end

  local remaining = ui.width - extrachars
  local cwd = vim.fn.fnamemodify(vim.loop.cwd(), ":~")
  local output = cwd:len() < remaining and cwd or vim.fn.pathshorten(cwd)
  return (" %s "):format(output)
end

function M.setup()
  local components = {
    M.padding(),
    M.cwd(),
    M.padding(),
  }
  return table.concat(components, "")
end

return M
