local M = {}

function M.space()
  return {
    provider = " ",
  }
end

function M.align()
  return {
    provider = "%=",
  }
end

M.icons = {
  close = "󰅙 ",
  left_arrow = " ",
  right_arrow = " ",
}

M.separators = {
  rounded_left = "",
  rounded_right = "",
  rounded_left_hollow = "",
  rounded_right_hollow = "",
  powerline_left = "",
  powerline_right = "",
  powerline_right_hollow = "",
  powerline_left_hollow = "",
  slant_left = "",
  slant_right = "",
  inverted_slant_left = "",
  inverted_slant_right = "",
  slant_ur = "",
  slant_br = "",
  vert = "│",
  vert_thick = "┃",
  block = "█",
  double_vert = "║",
  dotted_vert = "┊",
}

return M
