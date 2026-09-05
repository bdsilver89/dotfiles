local ns = vim.api.nvim_create_namespace("config_diricons")
vim.api.nvim_create_autocmd("User", {
  pattern = "DirReadPost",
  callback = function(ev)
    vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)
    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    for i, line in ipairs(lines) do
      if line ~= "" then
        local dir = line:sub(-1) == "/"
        local name = dir and line:sub(1, -2) or line
        local icon, hl = "", "Directory"
        if not dir then
          icon, hl = require("nvim-web-devicons").get_icon(name, vim.fn.fnamemodify(name, ":e"), { default = true })
        end
        vim.api.nvim_buf_set_extmark(ev.buf, ns, i - 1, 0, {
          virt_text = { { icon .. " ", hl } },
          virt_text_pos = "inline",
        })
      end
    end
  end
})

local clip = { paths = {}, cut = false }

local function dir_of()
  return vim.fs.normalize(vim.fs.abspath(vim.api.nvim_buf_get_name(0)), { plain = true })
end

local function entry_name()
  local line = vim.api.nvim_get_current_line()
  local name = line:sub(-1) == "/" and line:sub(1, -2) or line
  return name ~= "" and (name:gsub("%z", "\n")) or nil
end

local function selection()
  local first, last = vim.fn.line("."), vim.fn.line(".")
  if vim.fn.mode():find("[vV\22]") then
    vim.cmd("normal! \27")
    first, last = vim.fn.line("'<"), vim.fn.line("'>")
  end
  local dir, out = dir_of(), {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, first - 1, last, false)) do
    local name = line:sub(-1) == "/" and line:sub(1, -2) or line
    if name ~= "" then
      out[#out + 1] = vim.fs.joinpath(dir, (name:gsub("%z", "\n")))
    end
  end
  return out
end

local function reload(select)
  require("nvim.dir")._reload()
  if select then
    vim.fn.search([[\C\m^\V]] .. vim.fn.escape(select, [[\]]), "cw")
  end
end

local function copy_path(src, dst)
  local stat = vim.uv.fs_stat(src)
  if not stat then
    return false, src .. ": no such file"
  end
  if stat.type ~= "directory" then
    return vim.uv.fs_copyfile(src, dst)
  end
  if not vim.uv.fs_mkdir(dst, stat.mode) and not vim.uv.fs_stat(dst) then
    return false, dst .. ": mkdir failed"
  end
  for name in vim.fs.dir(src) do
    local ok, err = copy_path(vim.fs.joinpath(src, name), vim.fs.joinpath(dst, name))
    if not ok then
      return false, err
    end
  end
  return true
end

local function unique_dst(dir, name)
  if not vim.uv.fs_stat(vim.fs.joinpath(dir, name)) then
    return vim.fs.joinpath(dir, name)
  end
  local stem, ext = vim.fn.fnamemodify(name, ":r"), vim.fn.fnamemodify(name, ":e")
  ext = ext == "" and "" or "." .. ext
  for i = 1, 99 do
    local dst = vim.fs.joinpath(dir, ("%s (%d)%s"):format(stem, i, ext))
    if not vim.uv.fs_stat(dst) then
      return dst
    end
  end
end

local function create()
  local dir = dir_of()
  vim.ui.input({ prompt = "Create: " }, function(input)
    if not input or input == "" then
      return
    end
    local path, is_dir = vim.fs.joinpath(dir, input), input:sub(-1) == "/"
    vim.fn.mkdir(is_dir and path or vim.fs.dirname(path), "p")
    if not is_dir then
      local fd, err = vim.uv.fs_open(path, "a", 420)
      if not fd then
        return vim.notify("dir: " .. tostring(err), vim.log.levels.ERROR)
      end
      vim.uv.fs_close(fd)
    end
    reload((input:gsub("/.*$", "")))
  end)
end

local function rename()
  local name = entry_name()
  if not name then
    return
  end
  local dir = dir_of()
  vim.ui.input({ prompt = "Rename: ", default = name }, function(input)
    if not input or input == "" or input == name then
      return
    end
    local dst = vim.fs.joinpath(dir, input)
    vim.fn.mkdir(vim.fs.dirname(dst), "p")
    local ok, err = vim.uv.fs_rename(vim.fs.joinpath(dir, name), dst)
    if not ok then
      return vim.notify("dir: " .. tostring(err), vim.log.levels.ERROR)
    end
    reload(input)
  end)
end

local function delete()
  local paths = selection()
  if #paths == 0 then
    return
  end
  local names = table.concat(vim.tbl_map(vim.fs.basename, paths), ", ")
  vim.ui.select({ "no", "yes" }, { prompt = ("Delete %d: %s?"):format(#paths, names) }, function(choice)
    if choice ~= "yes" then
      return
    end
    for _, path in ipairs(paths) do
      local ok, err = pcall(vim.fs.rm, path, { recursive = true })
      if not ok then
        vim.notify("dir: " .. tostring(err), vim.log.levels.ERROR)
      end
    end
    reload()
  end)
end

local function stash(cut)
  local paths = selection()
  if #paths > 0 then
    clip = { paths = paths, cut = cut }
    vim.notify(("dir: %s %d"):format(cut and "cut" or "copied", #paths))
  end
end

local function paste()
  if #clip.paths == 0 then
    return vim.notify("dir: clipboard empty", vim.log.levels.WARN)
  end
  local dir, last = dir_of(), nil
  for _, src in ipairs(clip.paths) do
    local dst = unique_dst(dir, vim.fs.basename(src))
    if not dst then
      vim.notify("dir: no free name for " .. src, vim.log.levels.ERROR)
    else
      local ok, err
      if clip.cut then
        ok, err = vim.uv.fs_rename(src, dst)
        if not ok then
          ok, err = copy_path(src, dst)
          if ok then
            pcall(vim.fs.rm, src, { recursive = true })
          end
        end
      else
        ok, err = copy_path(src, dst)
      end
      if ok then
        last = vim.fs.basename(dst)
      else
        vim.notify("dir: " .. tostring(err), vim.log.levels.ERROR)
      end
    end
  end
  if clip.cut then
    clip = { paths = {}, cut = false }
  end
  reload(last)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "directory",
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set("n", "a", create, opts)
    vim.keymap.set("n", "r", rename, opts)
    vim.keymap.set({ "n", "x" }, "D", delete, opts)
    vim.keymap.set({ "n", "x" }, "yy", function() stash(false) end, opts)
    vim.keymap.set({ "n", "x" }, "x", function() stash(true) end, opts)
    vim.keymap.set("n", "p", paste, opts)
    vim.keymap.set("n", "gc", function() clip = { paths = {}, cut = false } end, opts)
  end,
})
