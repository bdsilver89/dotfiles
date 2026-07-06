vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
})

local parsers = {
  "bash",
  "c",
  "cmake",
  "css",
  "cpp",
  "go",
  "gitcommit",
  "html",
  "java",
  "javascript",
  "json",
  "json5",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "scss",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end

    pcall(vim.treesitter.language.add, lang)
    pcall(vim.treesitter.start, ev.buf, lang)

    vim.wo[0].foldmethod = "expr"
    vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.b[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
})

require("nvim-treesitter-textobjects").setup({
  select = {
    enable = true,
    lookahead = true,
  },
  move = {
    enable = true,
    set_jumps = true,
  },
})

local sel = require("nvim-treesitter-textobjects.select")
for _, map in ipairs({
  { { "x", "o" }, "af", "@function.outer" },
  { { "x", "o" }, "if", "@function.inner" },
}) do
  vim.keymap.set(map[1], map[2], function()
    sel.select_textobject(map[3], "textobjects")
  end, { desc = "Select " .. map[3] })
end

local mv = require("nvim-treesitter-textobjects.move")
for _, map in ipairs({
  { { "n", "x", "o" }, "]f", mv.goto_next_start, "@function.outer" },
  { { "n", "x", "o" }, "[f", mv.goto_previous_start, "@function.outer" },
}) do
  local modes = map[1]
  local lhs = map[2]
  local fn = map[3]
  local query = map[4]
  local qstr = (type(query) == "table") and  table.concat(query, ", ") or query
  vim.keymap.set(modes, lhs, function()
    fn(map[4], "textobjects")
  end, { desc = "Move to " .. qstr })
end
