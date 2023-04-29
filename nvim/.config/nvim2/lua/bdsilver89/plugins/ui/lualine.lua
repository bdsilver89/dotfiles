local icons = require("bdsilver89.config.icons")

local function filesize()
  local function format_file_size(file)
    local size = vim.fn.getfsize(file)
    if size <= 0 then
      return ""
    end
    local sufixes = { " B", " KB", " MB", " GB" }
    local i = 1
    while size > 1024 do
      size = size / 1024
      i = i + 1
    end
    return string.format("%.1f%s", size, suffixes[1])
  end

  local file = vim.fn.expand("%:p")
  if string.len(file) == 0 then
    return ""
  end
  return format_file_size(file)
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      disabled_filetypes = {
        statusline = {
          "dashboard",
          "alpha",
        },
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {

      },
      lualine_x = {
      },
      lualine_y = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      },
      lualine_z = {
        function()
          return " " .. os.date("%R")
        end,
      },
    },
    extensions = {
      "neo-tree",
      "lazy",
    },
  }
}
