local java_debug = vim
  .system({
    "mise",
    "where",
    "http:java-debug",
  }, { text = true })
  :wait()
assert(java_debug.code == 0, "Java debug plugin is not installed")

local java_debug_jar = vim.fs.joinpath(vim.trim(java_debug.stdout), "java-debug.jar")
assert(vim.fn.filereadable(java_debug_jar) == 1, "Java debug plugin not found: " .. java_debug_jar)

local function get_jdtls_cache_dir()
  return vim.fn.stdpath("cache") .. "/jdtls"
end

local function get_jdtls_workspace_dir()
  return get_jdtls_cache_dir() .. "/workspace"
end

local function get_jdtls_jvm_args()
  local env = os.getenv("JDTLS_JVM_ARGS")
  local args = {}
  for a in string.gmatch((env or ""), "%S+") do
    local arg = string.format("--jvm-arg=%s", a)
    table.insert(args, arg)
  end
  return unpack(args)
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local workspace_dir = get_jdtls_workspace_dir()
    local data_dir = workspace_dir

    if config.root_dir then
      data_dir = data_dir .. "/" .. vim.fn.fnamemodify(config.root_dir, ":p:h:t")
    end

    local config_cmd = {
      "jdtls",
      "-data",
      data_dir,
      get_jdtls_jvm_args(),
    }

    return vim.lsp.rpc.start(config_cmd, dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
  filetypes = { "java" },
  workspace_required = true,
  root_markers = {
    {
      "mvnw",
      "gradlew",
      "settings.gradle",
      "settings.gradle.kts",
    },
    {
      "build.xml",
      "pom.xml",
      "build.gradle",
      "build.gradle.kts",
    },
  },
  init_options = {
    bundles = { java_debug_jar },
  },
}
