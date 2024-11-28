local Notify = require("config.utils.notify")

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
    ["github%.com"] = {
      branch = "/tree/{branch}",
      file = "/blob/{branch}/{file}#L{line}",
      commit = "/commit/{commit}",
    },
    [".*gitlab.*%.com"] = { -- NOTE: wildcard here to help with various corporate gitlab providers
      branch = "/-/tree/{branch}",
      file = "/-/blob/{branch}/{file}#L{line}",
      commit = "/-/commit/{commit}",
    },
    ["bitbucket%.org"] = {
      branch = "/src/{branch}",
      file = "/src/{branch}/{file}#lines-{line}",
      commit = "/commits/{commit}",
    },
  },
}

local function system(cmd, err)
  local proc = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    Notify.error(table.concat({ err, proc }, "\n"), { title = "Git" })
    error(err)
  end
  return vim.split(vim.trim(proc), "\n")
end

local function is_valid_commit_hash(hash, cwd)
  if not (hash:match("^[a-fA-F0-9]+$") and #hash >= 7) then
    return false
  end
  system({ "git", "-C", cwd, "rev-parse", "--verify", hash }, "Invalid commit hash")
  return true
end

local function get_repo(remote, opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  local ret = remote
  for _, pattern in ipairs(opts.remote_patterns) do
    ret = ret:gsub(pattern[1], pattern[2]) --[[@as string]]
  end
  return ret:find("https://") == 1 and ret or ("https://%s"):format(ret)
end

local function get_url(repo, opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  for remote, patterns in pairs(opts.url_patterns) do
    Notify.info("repo=" .. repo .. ", remote=" .. remote)
    if repo:find(remote) then
      return patterns[opts.what] and (repo .. patterns[opts.what]) or repo
    end
  end
  return repo
end

local git_cache = {}
local function is_git_root(dir)
  if git_cache[dir] == nil then
    git_cache[dir] = vim.uv.fs_stat(dir .. "/.git") ~= nil
  end
  return git_cache[dir]
end

function M.get_root(path)
  path = path or 0
  path = type(path) == "number" and vim.api.nvim_buf_get_name(path) or path
  path = vim.fs.normalize(path)
  path = path == "" and vim.uv.cwd() .. "/foo" or path
  for dir in vim.fs.parents(path) do
    if git_cache[dir] then
      return vim.fs.normalize(dir) or nil
    end
  end
  for dir in vim.fs.parents(path) do
    if is_git_root(dir) then
      return vim.fs.normalize(dir) or nil
    end
  end
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
  local word = vim.fn.expand("<cword>")
  local is_commit = is_valid_commit_hash(word, cwd)
  local fields = {
    branch = system({ "git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD" }, "Failed to get current branch")[1],
    file = file and system({ "git", "-C", cwd, "ls-files", "--full-name", file }, "Failed to get git file path")[1],
    line = file and vim.fn.line("."),
    commit = is_commit and word,
  }

  if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    fields.line = file and start_line .. "-L" .. end_line
  else
    fields.line = file and vim.fn.line(".")
  end

  opts.what = is_commit and "commit" or opts.what == "commit" and not fields.commit and "file" or opts.what
  opts.what = not is_commit and opts.what == "file" and not fields.file and "branch" or opts.what
  opts.what = not is_commit and opts.what == "branch" and not fields.branch and "repo" or opts.what

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
      Notify.info(("Opening [%s](%s)"):format(remote.name, remote.url), { title = "Git Browse" })
      opts.open(remote.url)
    end
  end

  if #remotes == 0 then
    Notify.error("No git remotes found", { title = "Git Browse" })
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
