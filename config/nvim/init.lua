vim.loader.enable()

-- ============================================================================
-- Settings
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.cmdheight = 0
vim.o.cursorline = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.fillchars = { eob = " ", diff = "╱" }
vim.o.mouse = "a"
vim.o.number = true
vim.o.relativenumber = true
vim.o.ruler = false
vim.o.scrolloff = 8
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.termguicolors = true
vim.o.timeoutlen = vim.g.vscode and 1000 or 300
vim.o.undofile = true
vim.o.updatetime = 200
vim.o.winborder = "none"
vim.o.wrap = false

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

if vim.fn.has("nvim-0.12") == 1 then
  require("vim._extui").enable({
    enable = true,
    msg = {
      target = "cmd",
      timeout = 4000,
    },
  })
end

-- ============================================================================
-- VSCode
-- ============================================================================
if vim.g.vscode then
  vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
  vim.keymap.set("n", "<leader>/", function()
    vscode.call("workbench.action.findInFiles")
  end)
  return
end

-- ============================================================================
-- Plugins
-- ============================================================================
vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/tpope/vim-sleuth" },
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/nvim-mini/mini.nvim" },
})

pcall(vim.cmd.colorscheme, "catppuccin")

local mason_ensure_installed = {
  "lua-language-server",
  "stylua",

  "jdtls",

  "pyright",
  "ruff",

  "json-lsp",
  "yaml-language-server",

  "neocmakelsp",
}
require("mason").setup({})
local mr = require("mason-registry")
mr.refresh(function()
  for _, tool in ipairs(mason_ensure_installed) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end)

-- ============================================================================
-- Autocmds
-- ============================================================================
local group = vim.api.nvim_create_augroup("config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "help", "man", "qf" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = ev.buf })
  end,
})

