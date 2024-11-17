local Notify = require("config.utils.notify")

local M = setmetatable({}, {
  __call = function(t, ...)
    return t.open(...)
  end,
})

local defaults = {
  configure = true,
  config = {
    os = { editPreset = "nvim-remote" },
    gui = { nerdFontsVersion = "3" },
  },
  theme_path = vim.fs.normalize(vim.fn.stdpath("cache") .. "/lazygit-theme.yml"),
  theme = {
    [241] = { fg = "Special" },
    activeBorderColor = { fg = "MatchParen", bold = true },
    cherryPickedCommitBgColor = { fg = "Identifier" },
    cherryPickedCommitFgColor = { fg = "Function" },
    defaultFgColor = { fg = "Normal" },
    inactiveBorderColor = { fg = "FloatBorder" },
    optionsTextColor = { fg = "Function" },
    searchingActiveBorderColor = { fg = "MatchParen", bold = true },
    selectedLineBgColor = { bg = "Visual" }, -- set to `default` to have no background colour
    unstagedChangesColor = { fg = "DiagnosticError" },
  },
  win = {
    -- style = "lazygit",
  },
}

local dirty = true
local config_dir

local function env(opts)
  if not config_dir then
    local out = vim.fn.system({ "lazygit", "-cd" })
    local lines = vim.split(out, "\n", { plain = true })

    if vim.v.shell_error == 0 and #lines > 1 then
      config_dir = vim.split(lines[1], "\n", { plain = true })[1]
      vim.env.LG_CONFIG_FILE = vim.fs.normalize(config_dir .. "/config.yml" .. "," .. opts.theme_path)
    else
      local msg = {
        "Failed to get **lazygit** config directory.",
        "Will not apply **lazygit** config",
        "",
        "# Error:",
        vim.trim(out),
      }
      Notify.error(table.concat(msg, "\n"), { title = "Lazygit" })
    end
  end
end

local function get_color(v)
  local color = {}
  for _, c in ipairs({ "fg", "bg" }) do
    if v[c] then
      local name = v[c]
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      local hl_color
      if c == "fg" then
        hl_color = hl and hl.fg
      else
        hl_color = hl and hl.bg
      end
      if hl_color then
        table.insert(color, string.format("#%06x", hl_color))
      end
    end
  end
  if v.bold then
    table.insert(color, "bold")
  end
  return color
end

local function update_config(opts)
  local theme = {}

  for k, v in pairs(opts.theme) do
    if type(k) == "number" then
      local color = get_color(v)
      pcall(io.write, ("\27]4;%d;%s\7"):format(k, color[1]))
    else
      theme[k] = get_color(v)
    end
  end

  local config = vim.tbl_deep_extend("force", { gui = { theme = theme } }, opts.config or {})

  local function yaml_val(val)
    return type(val) == "string" and not val:find("^\"'`") and ("%q"):format(val) or val
  end

  local function to_yaml(tbl, indent)
    indent = indent or 0
    local lines = {}
    for k, v in pairs(tbl) do
      table.insert(lines, string.rep(" ", indent) .. k .. (type(v) == "table" and ":" or ": " .. yaml_val(v)))
      if type(v) == "table" then
        if (vim.islist or vim.tbl_islist)(v) then
          for _, item in ipairs(v) do
            table.insert(lines, string.rep(" ", indent + 2) .. "- " .. yaml_val(item))
          end
        else
          vim.list_extend(lines, to_yaml(v, indent + 2))
        end
      end
    end
    return lines
  end
  vim.fn.writefile(to_yaml(config), opts.theme_path)
  dirty = false
end

function M.open(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  local cmd = { "lazygit" }
  vim.list_extend(cmd, opts.args or {})

  if opts.configure then
    if dirty then
      Notify.info("UPDATING LAZYGIT CONFIG")
      update_config(opts)
    end
    env(opts)
  end

  return require("config.utils.terminal")(cmd, opts)
end

function M.log(opts)
  opts = opts or {}
  opts.args = opts.args or { "log" }
  return M.open(opts)
end

function M.log_file(opts)
  local file = vim.trim(vim.api.nvim_buf_get_name(0))
  opts = opts or {}
  opts.args = { "-f", file }
  opts.cwd = vim.fn.fnamemodify(file, ":h")
  return M.open(opts)
end

function M.setup()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      dirty = true
    end,
  })
end

return M
