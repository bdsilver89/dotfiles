local term = require("terminal")

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map("<leader>tt", function()
  term.shell(vim.v.count > 0 and vim.v.count or 1)
end, "Toggle terminal")

map("<leader>tn", function()
  term.new()
end, "New terminal")

map("<leader>ts", term.pick, "Select terminal")

map("<leader>tk", function()
  term.kill()
end, "Kill terminal")

map("<leader>tf", function()
  term.relayout("float")
end, "Terminal float")

map("<leader>th", function()
  term.relayout("horizontal")
end, "Terminal horizontal split")

map("<leader>tv", function()
  term.relayout("vertical")
end, "Terminal vertical split")

map("]t", function()
  term.cycle(1)
end, "Next terminal")

map("[t", function()
  term.cycle(-1)
end, "Prev terminal")

local tools = {
  { key = "<leader>tg", cmd = "lazygit", desc = "Lazygit" },
  { key = "<leader>td", cmd = "lazydocker", desc = "Lazydocker" },
  { key = "<leader>tp", cmd = "gh dash", desc = "GitHub dashboard" },
  { key = "<leader>ta", cmd = "gh enhance", desc = "GitHub Actions" },
}

for _, tool in ipairs(tools) do
  map(tool.key, function()
    term.toggle(tool.cmd, { cmd = tool.cmd, tui = true })
  end, tool.desc)
end

map("<leader>gg", function()
  term.toggle("lazygit", { cmd = "lazygit", tui = true })
end, "Lazygit")
