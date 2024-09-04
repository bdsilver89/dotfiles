local M = {}

local config = {
  show_file_path = true,
  show_symbols = true,
  -- TODO: add option for enable_icons = false
  icons = {
    file_icon_default = "",
    separator = ">",
    editor_state = "●",
    lock_icon = "",
  },
  exclude_filetype = {
    "help",
    "dashboard",
    "neogitstatus",
    "NvimTree",
    "Trouble",
    "toggleterm",
    "qf",
  },
}

local hl_winbar_path = "WinBarPath"
local hl_winbar_file = "WinBarFile"
local hl_winbar_symbols = "WinBarSymbols"
local hl_winbar_file_icon = "WinBarFileIcon"

local function winbar()
  local file_path = vim.fn.expand("%:~:.:h")
  local filename = vim.fn.expand("%:t")
  local file_type = vim.fn.expand("%:e")
  local value = " "
  local file_icon = ""

  file_path = file_path:gsub("^%.", "")
  file_path = file_path:gsub("^%/", "")

  if filename == nil or filename == "" then
    return ""
  end

  local default = false
  if file_type == nil or file_type == "" then
    file_type = ""
    default = true
  end

  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    file_icon = devicons.get_icon_color(filename, file_type, { default = default })
    hl_winbar_file_icon = "DevIcon" .. file_type
  end
  if not file_icon then
    file_icon = "" -- TODO: default file icon
  end

  file_icon = "%#" .. hl_winbar_file_icon .. "#" .. file_icon .. " %*"

  if config.show_file_path then
    local file_path_list = {}
    local _ = string.gsub(file_path, "[^/]+", function(w)
      table.insert(file_path_list, w)
    end)

    for i = 1, #file_path_list do
      value = value .. "%#" .. hl_winbar_path .. "#" .. file_path_list[i] .. " " .. config.icons.separator .. " %*"
    end
  end

  value = value .. file_icon
  value = value .. "%#" .. hl_winbar_file .. "#" .. filename .. "%*"

  -- local has_lspkind, lspkidn = pcall(require, "lspkind")
  -- local has_trouble, trouble = pcall(require, "trouble")
  -- if has_trouble then
  --   value = value .. " trouble"
  --   if has_lspkind then
  --     value = value .. " lspkind"
  --   end
  -- end

  return value
end

local function show_winbar()
  if vim.tbl_contains(config.exclude_filetype, vim.bo.filetype) then
    vim.opt_local.winbar = nil
    return
  end

  local value = winbar()
  pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local", win = 0 })
end

function M.setup()
  vim.api.nvim_set_hl(0, hl_winbar_path, { fg = "" })
  vim.api.nvim_set_hl(0, hl_winbar_file, { fg = "" })
  vim.api.nvim_set_hl(0, hl_winbar_symbols, { fg = "" })

  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufWinEnter", "FileType", "TermOpen" }, {
    callback = function()
      show_winbar()
    end,
  })
end

return M
