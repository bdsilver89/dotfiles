vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/NMAC427/guess-indent.nvim",
  "https://github.com/windwp/nvim-ts-autotag",
})

require("nvim-ts-autotag").setup()
require("guess-indent").setup({})

local parsers = {
  "bash",
  "diff",
  "query",
  "regex",
  "vim",
  "vimdoc",
}
vim.list_extend(parsers, require("lang").parsers)

require("nvim-treesitter").install(parsers)

local available_parsers = require("nvim-treesitter").get_installed("parsers")

---@param buf number
---@param lang string
local function ts_start(buf, lang)
  vim.treesitter.start(buf)

  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  if vim.treesitter.query.get(lang, "indents") ~= nil then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_tsft", { clear = true }),
  pattern = vim
    .iter(parsers)
    :map(function(p)
      return vim.treesitter.language.get_filetypes(p)
    end)
    :flatten()
    :totable(),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end

    if not vim.tbl_contains(available_parsers, lang) then
      require("nvim-treesitter").install(lang):await(function()
        ts_start(ev.buf, lang)
      end)
    else
      ts_start(ev.buf, lang)
    end
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config_packchangedts", { clear = true }),
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end

    if name == "nvim-treesitter" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
})

vim.keymap.set({ "x", "o" }, "af", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]f", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[f", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]z", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
end)
vim.keymap.set({ "n", "x", "o" }, "[z", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end("@fold", "folds")
end)

-- vim.keymap.set({ "n", "x", "o" }, ";", function()
--   require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_next()
--   -- require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move()
-- end)
-- vim.keymap.set({ "n", "x", "o" }, ",", function()
--   require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_previous()
--   -- require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_opposite()
-- end)

-- vim.keymap.set({ "n", "x", "o" }, "f", function()
--   require("nvim-treesitter-textobjects.repeatable_move").builtin_f_expr()
-- end, { expr = true })
-- vim.keymap.set({ "n", "x", "o" }, "F", function()
--   require("nvim-treesitter-textobjects.repeatable_move").builtin_F_expr()
-- end, { expr = true })
-- vim.keymap.set({ "n", "x", "o" }, "t", function()
--   require("nvim-treesitter-textobjects.repeatable_move").builtin_t_expr()
-- end, { expr = true })
-- vim.keymap.set({ "n", "x", "o" }, "T", function()
--   require("nvim-treesitter-textobjects.repeatable_move").builtin_T_expr()
-- end, { expr = true })
