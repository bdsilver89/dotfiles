local icons = require("icons")

local M = {}

function M.render()
  local path = vim.fs.normalize(vim.fn.expand("%:p"))

  if vim.startswith(path, "diffview") then
    return string.format("%%#Winbar#%s", path)
  end

  local separator = ' %#WinbarSeparator# '

  local prefix, prefix_path = "", ""

  if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
    path = vim.fn.pathshorten(path)
  else
    local special_dirs = {
      HOME = vim.env.HOME,
      PROJECTS = vim.g.projects_dir,
    }
    for dir_name, dir_path in pairs(special_dirs) do
      if vim.startswith(path, vim.fs.normalize(dir_path)) and #dir_path > #prefix then
        prefix, prefix_path = dir_name, dir_path
      end
    end
    if prefix ~= "" then
      path = path:gsub("^" .. vim.pesc(prefix_path), "")
      prefix = string.format("%%#WinBarDir#%s %s%s", icons.symbol_kinds.Folder, prefix, separator)
    end
  end

  path = path:gsub("^/", "")

  return table.concat({
    " ",
    prefix,
    table.concat(
      vim.iter(vim.split(path, "/"))
        :map(function(segment)
          return string.format("%%#Winbar#%s", segment)
        end)
        :totable(),
      separator
    )
  })
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("config_winbar", { clear = true }),
  callback = function(ev)
    if
      not vim.api.nvim_win_get_config(0).zindex and
      vim.bo[ev.buf].buftype == "" and
      vim.api.nvim_buf_get_name(ev.buf) ~= "" and
      not vim.wo[0].diff
    then
      vim.wo.winbar = "%{%v:lua.require'winbar'.render()%}"
    end
  end,
})

return M
