local build_systems = {
  c = {
    { marker = "CMakeLists.txt", compiler = "gcc", makeprg = "cmake" },
  },
  cpp = "c",
  java = {
    { marker = "pom.xml", compiler = "maven", makeprg = "mvn --batch-mode $*" },
  }
}

local cache = {}

local function detect_build_system()
  local ft = vim.bo.filetype
  local rules = build_systems[ft]
  if type(rules) == "string" then rules = build_systems[rules] end
  if not rules then return end

  local buf_dir = vim.fn.expand("%:p:h")
  if cache[buf_dir] then
    vim.cmd.compiler(cache[buf_dir].compiler)
    if cache[buf_dir].makeprg then
      vim.bo.makeprg = cache[buf_dir].makeprg
    end
    return
  end

  for _, rule in ipairs(rules) do
    local found = vim.fs.find(rule.marker, { upward = true, path = buf_dir, stop = vim.env.HOME })
    if found[1] then
      local root = vim.fn.fnamemodify(found[1], ":h")
      vim.cmd.compiler(rule.compiler)
      if rule.makeprg then
        vim.bo.makeprg = rule.makeprg
      end
      cache[buf_dir] = { compiler = rule.compiler, makeprg = vim.bo.makeprg }
      return
    end
  end
end

local group = vim.api.nvim_create_augroup("build", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = vim.tbl_keys(build_systems),
  callback = detect_build_system,
})

vim.api.nvim_create_autocmd("DirChanged", {
  group = group,
  callback = function()
    cache = {}
    detect_build_system()
  end,
})
