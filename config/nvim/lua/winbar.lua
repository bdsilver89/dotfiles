if vim.g.vscode then
  return
end

local M = {}

function M.render()
  local path = vim.fs.normalize(vim.fn.expand("%:p"))

  if vim.startswith(path, "diffview") then
    return string.format("%%Winbar#%s", path)
  end

  local separator = " %#WinbarSeparator# "

  local prefix, prefix_path = "", ""

  if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
    path = vim.fn.pathshorten(path)
  else
    local special_dirs = {
      HOME = vim.env.HOME,
    }

    for dir_name, dir_path in pairs(special_dirs) do
      if vim.startswith(path, vim.fs.normalize(dir_path)) and #dir_path > #prefix_path then
        prefix, prefix_path = dir_name, dir_path
      end
    end

    if prefix ~= "" then
      path = path:gsub("^" .. prefix_path, "")
      prefix = string.format("%%#WinBarDir#󰉋  %s%s", prefix, separator)
    end
  end

  path = path:gsub("^/", "")
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
  })
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("bdsilver89/winbar", { clear = true }),
  desc = "Attach winbar",
  callback = function(args)
    if
      not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
      and vim.bo[args.buf].buftype == "" -- Normal buffer
      and vim.api.nvim_buf_get_name(args.buf) ~= "" -- Has a file name
      and not vim.wo[0].diff -- Not in diff mode
    then
      vim.wo.winbar = "%{%v:lua.require'winbar'.render()%}"
    end
  end,
})

local function create_hl()
  local get_highlight = function(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
  end

  local winbar = get_highlight("WinBar")
  local cyan = get_highlight("Function").fg

  local groups = {
    WinBarDir = { fg = cyan, bg = winbar.bg, italic = true },
    WinBarSeparator = { fg = cyan, bg = winbar.bg },
  }

  for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = create_hl,
})

return M
