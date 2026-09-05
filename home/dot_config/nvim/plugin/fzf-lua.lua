vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
})

local loaded = false

---@param cmd string
local function run_cmd(cmd)
  if not loaded then
    loaded = true
    local fzf = require("fzf-lua")
    fzf.config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    fzf.setup({ ui_select = {} })
  end
  require("fzf-lua.cmd").run_command(cmd)
end

vim.keymap.set("n", "<leader>fb", function() run_cmd("buffers") end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>ff", function() run_cmd("files") end, { desc = "Files" })

vim.keymap.set("n", "<leader>sc", function() run_cmd("command_history") end, { desc = "Command history" })
vim.keymap.set("n", "<leader>sg", function() run_cmd("live_grep") end, { desc = "Grep" })

-- vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Buffers" })
-- vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Files" })
-- vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "Files (git)" })
-- vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent" })
--
-- vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Commits" })
-- vim.keymap.set("n", "<leader>gd", "<cmd>FzfLua git_diff<cr>", { desc = "Diff" })
-- vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>", { desc = "Status" })
-- vim.keymap.set("n", "<leader>gS", "<cmd>FzfLua git_stash<cr>", { desc = "Stash" })
--
-- vim.keymap.set("n", "<leader>s/", "<cmd>FzfLua search_history<cr>", { desc = "Search history" })
-- vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua buffers<cr>", { desc = "Lines" })
-- vim.keymap.set("n", "<leader>sc", "<cmd>FzfLua command_history<cr>", { desc = "Command history" })
-- vim.keymap.set("n", "<leader>sC", "<cmd>FzfLua commands<cr>", { desc = "Commands" })
-- vim.keymap.set("n", "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Diagnostics" })
-- vim.keymap.set("n", "<leader>sD", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Diagnostics buffer" })
-- vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
-- vim.keymap.set("n", "<leader>sk", "<cmd>FzfLua keymaps<cr>", { desc = "Keymaps" })
-- vim.keymap.set("n", "<leader>sR", "<cmd>FzfLua resume<cr>", { desc = "Resume" })
-- vim.keymap.set({ "n", "x" }, "<leader>sw", "<cmd>FzfLua grep_cword<cr>", { desc = "Word" })

vim.keymap.set("n", "<leader><space>", "<leader>ff", { desc = "Files", remap = true })
vim.keymap.set("n", "<leader>,", "<leader>fb", { desc = "Buffers", remap = true })
vim.keymap.set("n", "<leader>:", "<leader>sc", { desc = "Command history", remap = true })
vim.keymap.set("n", "<leader>/", "<leader>sg", { desc = "Grep", remap = true })
