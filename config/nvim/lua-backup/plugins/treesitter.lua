vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/windwp/nvim-ts-autotag",
})

require("nvim-treesitter").setup({
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "cmake",
    "java",
    "markdown",
    "make",
    "rust",
    "python",
    "toml",
    "javascript",
    "typescript",
    "tsx",
    "json",
    "lua",
    "yaml",
    "xml",
  },
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config_tsupdate", { clear = true }),
  callback = function(ev)
    if ev.data.kind == "update" then
      local ok = pcall(vim.cmd, "TSUpdate")
      if not ok then
        vim.notify("TSUpdate completed", vim.log.levels.INFO)
      end
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local ok = pcall(vim.treesitter.start)
    if not ok then
      return
    end

    vim.wo[0].foldmethod = "expr"
    vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

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

require("nvim-ts-autotag").setup()
