-- stylua: ignore start
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- stylua: ignore end

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>")
vim.keymap.set("n", "<leader>-", "<c-w>s")
vim.keymap.set("n", "<leader>|", "<c-w>v")

vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "[<tab>", "<cmd>tabprev<cr>", { desc = "Prev Tab" })

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })

vim.keymap.set({ "i", "s" }, "<tab>", function()
  if vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  elseif not vim.lsp.inline_completion.get() then
    return "<tab>"
  end
end, { desc = "Next Snippet", expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<s-tab>", function()
  if vim.snippet.active({ direction = -1 }) then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  else
    return "<s-tab>"
  end
end, { desc = "Prev Snippet", expr = true, silent = true })

vim.keymap.set("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle Diagnostics" })

vim.keymap.set("n", "<leader>uw", function()
  vim.o.wrap = not vim.o.wrap
end, { desc = "Toggle Wrap" })

vim.keymap.set("n", "<leader>ut", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Undotree" })

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("n", "<leader>xl", function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then vim.cmd.lclose() else vim.cmd.lopen() end
end, { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then vim.cmd.cclose() else vim.cmd.copen() end
end, { desc = "Quickfix List" })

-- textobjects
for _, map in ipairs({
  { { "x", "o" }, "af", "@function.outer" },
  { { "x", "o" }, "if", "@function.inner" },
  { { "x", "o" }, "ac", "@class.outer" },
  { { "x", "o" }, "ic", "@class.inner" },
  { { "x", "o" }, "aa", "@parameter.outer" },
  { { "x", "o" }, "ia", "@parameter.inner" },
}) do
  vim.keymap.set(map[1], map[2], function()
    require("nvim-treesitter-textobjects.select").select_textobject(map[3], "textobjects")
  end, { desc = "Select " .. map[3] })
end
for _, map in ipairs({
  { { "n", "x", "o" }, "]f", "goto_next_start", "@function.outer" },
  { { "n", "x", "o" }, "[f", "goto_previous_start", "@function.outer" },
  { { "n", "x", "o" }, "]c", "goto_next_start", "@class.outer" },
  { { "n", "x", "o" }, "[c", "goto_previous_start", "@class.outer" },
}) do
  local modes, lhs, fn, query = map[1], map[2], map[3], map[4]
  local qstr = (type(query) == "table") and table.concat(query, ",") or query
  vim.keymap.set(modes, lhs, function()
    require("nvim-treesitter-textobjects.move")[fn](query, "textobjects")
  end, { desc = "Move to " .. qstr })
end

-- stylua: ignore start
vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
-- stylua: ignore end

-- tmux
local function navigate(vdir, tdir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(vdir)
  if (vim.env.TMUX ~= nil) and vim.api.nvim_get_current_win() == win then
    vim.system({ "tmux", "select-pane", "-" .. tdir })
  end
end
vim.keymap.set({ "n", "t" }, "<c-h>", function() navigate("h", "L") end)
vim.keymap.set({ "n", "t" }, "<c-j>", function() navigate("j", "D") end)
vim.keymap.set({ "n", "t" }, "<c-k>", function() navigate("k", "U") end)
vim.keymap.set({ "n", "t" }, "<c-l>", function() navigate("l", "R") end)

