-- Treesitter's main branch changed the API: you install parsers and start them
-- yourself. This is what breaks when copying older configs.
local treesitter = require("nvim-treesitter")
treesitter.setup({})

treesitter.install({
  "c", "cpp", "cmake", "rust", "python", "javascript", "typescript", "tsx",
  "bash", "html", "css", "json", "yaml", "toml", "lua", "luadoc", "vim",
  "vimdoc", "markdown", "markdown_inline", "dockerfile", "diff", "git_rebase",
  "gitcommit", "regex", "query",
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
  callback = function(ev)
    if vim.b[ev.buf].large_file then
      return
    end
    pcall(vim.treesitter.start, ev.buf)
  end,
})

require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })

local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
for lhs, obj in pairs({
  af = "@function.outer",
  ["if"] = "@function.inner",
  ac = "@class.outer",
  ic = "@class.inner",
  aa = "@parameter.outer",
  ia = "@parameter.inner",
}) do
  vim.keymap.set({ "x", "o" }, lhs, function()
    select_textobject(obj, "textobjects")
  end, { desc = "Textobject " .. obj })
end

require("mini.ai").setup()
require("mini.surround").setup()
require("mini.pairs").setup()
require("mini.statusline").setup()

local fzf = require("fzf-lua")
fzf.setup({ "default-title", winopts = { preview = { layout = "vertical" } } })

local map = vim.keymap.set
map("n", "<leader><space>", fzf.files, { desc = "Find files" })
map("n", "<leader>/", fzf.live_grep, { desc = "Grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fh", fzf.helptags, { desc = "Help" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume picker" })
map("n", "<leader>fd", fzf.diagnostics_workspace, { desc = "Diagnostics" })
map("n", "<leader>fg", fzf.git_status, { desc = "Git status" })

-- oil edits directories as buffers. Swap for neo-tree if you want a sidebar,
-- but pick one.
require("oil").setup({ view_options = { show_hidden = true } })
map("n", "-", "<cmd>Oil<cr>", { desc = "Parent directory" })

require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = { delay = 400 },
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function m(lhs, rhs, desc)
      map("n", lhs, rhs, { buffer = buf, desc = desc })
    end
    m("]h", function()
      gs.nav_hunk("next")
    end, "Next hunk")
    m("[h", function()
      gs.nav_hunk("prev")
    end, "Prev hunk")
    m("<leader>hs", gs.stage_hunk, "Stage hunk")
    m("<leader>hr", gs.reset_hunk, "Reset hunk")
    m("<leader>hp", gs.preview_hunk, "Preview hunk")
    m("<leader>hb", gs.blame_line, "Blame line")
  end,
})

require("diffview").setup({ enhanced_diff_hl = true })
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diff working tree" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })

require("which-key").setup({ preset = "helix" })
require("persistence").setup()
