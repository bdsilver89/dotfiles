require("lualine").setup({
  options = {
    component_separators = "",
    section_separators = "",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { { "filename", path = 4 } },
    lualine_x = {
      {
        function()
          return "Recording @" .. vim.fn.reg_recording()
        end,
        cond = function()
          return vim.fn.reg_recording() ~= ""
        end,
        padding = 1,
      },
      "encoding",
      "fileformat",
      "filetype",
    },
    lualine_y = { "progress", },
    lualine_z = { "location" },
  },
})
