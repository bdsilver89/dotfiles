local map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

map("n", "<leader>-", "<c-w>s", { desc = "Split below", remap = true })
map("n", "<leader>|", "<c-w>v", { desc = "Split right", remap = true })

map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "[<tab>", "<cmd>tabprev<cr>", { desc = "Prev tab" })

map("x", "<", "<gv")
map("x", ">", ">gv")

map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location list" })

map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix list" })

map("n", "<esc>", "<cmd>nohlsearch<cr><esc>", { desc= "Clear hlsearch" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("t", "<esc><esc>", "<c-\\><c-n>")

map("n", "-", "<cmd>Oil<cr>", { desc = "File explorer (oil)" })

-- local textobjects = {
--   select = {
--     select_textobject = {
--       ["ak"] = "@block.outer",
--       ["ik"] = "@block.inner",
--       ["ac"] = "@class.outer",
--       ["ic"] = "@class.inner",
--       ["a?"] = "@conditional.outer",
--       ["i?"] = "@conditional.inner",
--       ["al"] = "@loop.outer",
--       ["il"] = "@loop.inner",
--       ["af"] = "@function.outer",
--       ["if"] = "@function.inner",
--       ["aa"] = "@parameter.outer",
--       ["ia"] = "@parameter.inner",
--     },
--   },
--   move = {
--     goto_next_start = {
--       ["]f"] = "@function.outer",
--       ["]c"] = "@class.outer",
--       ["]a"] = "@parameter.outer",
--     },
--     goto_next_end = {
--       ["]F"] = "@function.outer",
--       ["]C"] = "@class.outer",
--       ["]A"] = "@parameter.outer",
--     },
--     goto_previous_start = {
--       ["[f"] = "@function.outer",
--       ["[c"] = "@class.outer",
--       ["[a"] = "@parameter.outer",
--     },
--     goto_previous_end = {
--       ["[F"] = "@function.outer",
--       ["[C"] = "@class.outer",
--       ["[A"] = "@parameter.outer",
--     },
--   },
--   swap = {
--     swap_next = {
--       [">K"] = "@block.outer",
--       [">F"] = "@function.outer",
--       [">A"] = "@parameter.inner",
--     },
--     swap_previous = {
--       ["<K"] = "@block.outer",
--       ["<F"] = "@function.outer",
--       ["<A"] = "@parameter.inner",
--     },
--   },
-- }
--
-- for type, keys in pairs(textobjects) do
--   for method, keymaps in pairs(keys) do
--     for key, query in pairs(keymaps) do
--       local desc = query:gsub("@", ""):gsub("%..*", "")
--       desc = desc:sub(1, 1):upper() .. desc:sub(2)
--       desc = (key:sub(1, 1) == "[" and "Prev" or "Next") .. " " .. desc
--       desc = desc .. " " .. (key:sub(2, 2) == key:sub(2, 2):upper() and "end" or "start")
--
--       if not (vim.wo.diff and key:find("[cC]")) then
--         map({ "n", "x", "o" }, key, function()
--           require("nvim-treesitter-textobjects." .. type)[method](query, "textobjects")
--         end, { desc = desc })
--       end
--     end
--   end
-- end
