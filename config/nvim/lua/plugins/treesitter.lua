vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
})

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    enable = true,
    set_jumps = true,
  },
})

local select = require("nvim-treesitter-textobjects.select")
for _, map in ipairs({
  -- { { "x", "o" }, "ak", "@block.outer" },
  -- { { "x", "o" }, "ik", "@block.inner" },
  { { "x", "o" }, "af", "@function.outer" },
  { { "x", "o" }, "if", "@function.inner" },
  { { "x", "o" }, "ac", "@class.outer" },
  { { "x", "o" }, "ic", "@class.inner" },
  { { "x", "o" }, "a?", "@conditional.outer" },
  { { "x", "o" }, "i?", "@conditional.inner" },
  { { "x", "o" }, "al", "@loop.outer" },
  { { "x", "o" }, "il", "@loop.inner" },
  { { "x", "o" }, "aa", "@parameter.outer" },
  { { "x", "o" }, "ia", "@parameter.inner" },
}) do
  vim.keymap.set(map[1], map[2], function()
    select.select_texobject(map[3], "textobjects")
  end, { desc = "Select " .. map[3] })
end

local move = require("nvim-treesitter-textobjects.move")
for _, map in ipairs({
  { { "n", "x", "o" }, "]f", "goto_next_start", "@function.outer" },
  { { "n", "x", "o" }, "[f", "goto_previous_start", "@function.outer" },
  { { "n", "x", "o" }, "]c", "goto_next_start", "@class.outer" },
  { { "n", "x", "o" }, "[c", "goto_previous_start", "@class.outer" },
  { { "n", "x", "o" }, "]a", "goto_next_start", "@parameter.inner" },
  { { "n", "x", "o" }, "[a", "goto_previous_start", "@parameter.inner" },
}) do
  vim.keymap.set(map[1], map[2], function()
    move[map[3]](map[4], "textobjects")
  end, { desc = "Move to " .. map[3] })
end


vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_ts", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local lang = vim.treesitter.language.get_lang(ev.match)
    if lang and require("nvim-treesitter.parsers")[lang] then
      pcall(require("nvim-treesitter").install, { lang })
    end
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
