vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/catppuccin/nvim", name = "nvim" },
  { src = "https://github.com/tpope/vim-sleuth" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/saghen/blink.cmp" },
  { src = "https://github.com/nvim-mini/mini.nvim" },
})

require("catppuccin").setup({})
vim.cmd.colorscheme("catppuccin")

local mason_ensure_installed = {
  "lua-language-server",
  "stylua",

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

require("gitsigns").setup({})

require("blink.cmp").setup({
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
  snippets = {
    preset = "default",
  },
  keymap = {
    preset = "default",
    ["<cr>"] = { "accept", "fallback" },
    ["<c-b>"] = { "scroll_documentation_up", "fallback" },
    ["<c-f>"] = { "scroll_documentation_down", "fallback" },
    ["<tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<s-tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    menu = {
      draw = {
        treesitter = { "lsp" },
      },
    },
    ghost_text = { enabled = true },
  },
})

require("oil").setup({})

local ts_ensure_installed = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "diff",
  "git_config",
  "gitcommit",
  "git_rebase",
  "gitignore",
  "gitattributes",
  -- "go",
  -- "gomod",
  -- "gosum",
  -- "gowork",
  "html",
  "http",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "jsonc",
  "lua",
  "luadoc",
  "luap",
  "make",
  "markdown",
  "markdown_inline",
  "ninja",
  "printf",
  "python",
  "query",
  "regex",
  "rust",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

local ts = require("nvim-treesitter")
ts.setup({})
local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 end
local to_install = vim.tbl_filter(isnt_installed, ts_ensure_installed)
if #to_install > 0 then
  ts.install(to_install)
end

local filetypes = vim.iter(ts_ensure_installed):map(vim.treesitter.language.get_filetypes):flatten():totable()
local ts_start = function(ev) vim.treesitter.start(ev.buf) end
vim.api.nvim_create_autocmd("FileType", {
  pattern = filetypes,
  callback = ts_start,
})

require("nvim-treesitter-textobjects").setup({
  select = {
    enable = true,
    lookahead = true,
  },
  move = {
    enable = true,
  }
})

require("mini.extra").setup({})
require("mini.bufremove").setup({})
require("mini.pick").setup({})
