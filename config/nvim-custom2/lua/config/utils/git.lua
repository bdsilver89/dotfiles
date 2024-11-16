local M = {}

local defaults = {
  open = function(url)
    vim.ui.open(url)
  end,
  what = "file",
  remote_patterns = {
    { "^(https?://.*)%.git$", "%1" },
    { "^git@(.+):(.+)%.git$", "https://%1/%2" },
    { "^git@(.+):(.+)$", "https://%1/%2" },
    { "^git@(.+)/(.+)$", "https://%1/%2" },
    { "^ssh://git@(.*)$", "https://%1" },
    { "^ssh://([^:/]+)(:%d+)/(.*)$", "https://%1/%3" },
    { "^ssh://([^/]+)/(.*)$", "https://%1/%2" },
    { "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
    { "^https://%w*@(.*)", "https://%1" },
    { "^git@(.*)", "https://%1" },
    { ":%d+", "" },
    { "%.git$", "" },
  },
  url_patterns = {
    ["github.com"] = {
      branch = "/tree/{branch}",
      file = "/blob/{branch}/{file}#L{line}",
    },
    ["gitlab.com"] = {
      branch = "/-/tree/{branch}",
      file = "/-/blob/{branch}/{file}#L{line}",
    },
  },
}

local function system(cmd, err)
  local proc = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(table.concat({ err, proc }, "\n"), vim.log.levels.ERROR, { title = "Git" })
    error(err)
  end
  return vim.split(vim.trim(proc), "\n")
end

local function get_repo(remote, opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  local ret = remote
  for _, pattern in ipairs(opts.remote_patterns) do
    ret = ret:gsub(pattern[1], pattern[2])
  end
  return ret:find("https://") == 1 and ret or ("https://%s"):format(ret)
end

local function get_url(repo, opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  for remote, patterns in pairs(opts.url_patterns) do
    if repo:find(remote) then
      return patterns[opts.what] and (repo .. patterns[opts.what]) or repo
    end
  end
  return repo
end

function M.get_root(path)
  path = path or 0
  path = type(path) == "number" and vim.api.nvim_buf_get_name(path) or path
  path = vim.fs.normalize(path)
  local git_root = vim.fs.find(".git", { path = path, upward = true })[1]
  return git_root and vim.fn.fnamemodify(git_root, ":h") or nil
end

function M.blame_line(opts)
  opts = vim.tbl_deep_extend("force", {
    count = 5,
    interactice = false,
    win = {
      width = 0.6,
      height = 0.6,
      border = "rounded",
      title = "Git Blame",
      title_pos = "center",
      ft = "git",
    },
  }, opts or {})

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  local file = vim.api.nvim_buf_get_name(0)
  local root = M.get_root()
  local cmd = { "git", "-C", root, "log", "-n", opts.count, "-u", "-L", line .. ",+1:" .. file }
  return require("config.utils.terminal")(cmd, opts)
end

function M.browse(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  local file = vim.api.nvim_buf_get_name(0)
  file = file and (vim.uv.fs_stat(file) or {}).type == "file" and vim.fs.normalize(file) or nil
  local cwd = file and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
  local fields = {
    branch = system({ "git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD" }, "Failed to get current branch")[1],
    file = file and system({ "git", "-C", cwd, "ls-files", "--full-name", file }, "Failed to get git file path")[1],
    line = file and vim.fn.line("."),
  }
  opts.what = opts.what == "file" and not fields.file and "branch" or opts.what
  opts.what = opts.what == "branch" and not fields.branch and "repo" or opts.what

  local remotes = {}

  for _, line in ipairs(system({ "git", "-C", cwd, "remote", "-v" }, "Failed to get git remotes")) do
    local name, remote = line:match("(%S+)%s+(%S+)%s+%(fetch%)")
    if name and remote then
      local repo = get_repo(remote, opts)
      if repo then
        table.insert(remotes, {
          name = name,
          url = get_url(repo, opts):gsub("(%b{})", function(key)
            return fields[key:sub(2, -2)] or key
          end),
        })
      end
    end
  end

  local function open(remote)
    if remote then
      vim.notify(("Opening [%s](%s)"):format(remote.name, remote.url), vim.log.levels.INFO, { title = "Git Browse" })
      opts.open(remote.url)
    end
  end

  if #remotes == 0 then
    vim.notify("No git remotes found", vim.log.levels.ERROR, { title = "Git Browse" })
    return
  elseif #remotes == 1 then
    return open(remotes[1])
  end

  vim.ui.select(remotes, {
    prompt = "Select remote to browse",
    format_item = function(item)
      return item.name .. (" "):rep(8 - #item.name) .. " " .. item.url
    end,
  }, open)
end

return M
