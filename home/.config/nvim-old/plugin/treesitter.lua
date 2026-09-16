vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
})

require("nvim-treesitter").install({
  "bash",
  "c", "cmake", "cpp",
  "gitcommit",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "markdown", "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "tsx", "typescript",
  "vim", "vimdoc",
  "xml",
  "yaml",
})

local group = vim.api.nvim_create_augroup("configts", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    local buf, filetype = ev.buf, ev.match
    local lang = vim.treesitter.language.get_lang(filetype)

    if not lang then return end
    if not vim.treesitter.language.add(lang) then return end
    if not vim.api.nvim_buf_is_valid(buf) then return end

    if pcall(vim.treesitter.start, buf, lang) then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = vim.treesitter.foldexpr

      if vim.treesitter.query.get(lang, "indents") ~= nil then
        vim.bo[buf].indentexpr = require("nvim-treesitter").indentexpr
      end
    else
      vim.bo[buf].syntax = "on"
    end
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end
    if name == "nvim-treesitter" then
      vim.cmd("TSUpdate")
    end
  end,
})

local textobjects = {
  { { "x", "o" }, "ik", "select.select_textobject", "@block.inner", "Inside block" },
  { { "x", "o" }, "ak", "select.select_textobject", "@block.outer", "Around block" },
  { { "x", "o" }, "ic", "select.select_textobject", "@class.inner", "Inside class" },
  { { "x", "o" }, "ac", "select.select_textobject", "@class.outer", "Around class" },
  { { "x", "o" }, "if", "select.select_textobject", "@function.inner", "Inside function" },
  { { "x", "o" }, "af", "select.select_textobject", "@function.outer", "Around function" },
  { { "x", "o" }, "io", "select.select_textobject", "@loop.inner", "Inside loop" },
  { { "x", "o" }, "ao", "select.select_textobject", "@loop.outer", "Around loop" },
  { { "x", "o" }, "i?", "select.select_textobject", "@conditional.inner", "Inside conditional" },
  { { "x", "o" }, "a?", "select.select_textobject", "@conditional.outer", "Around conditional" },
  { { "x", "o" }, "ia", "select.select_textobject", "@parameter.inner", "Inside argument" },
  { { "x", "o" }, "aa", "select.select_textobject", "@parameter.outer", "Around argument" },

  { { "n", "x", "o" }, "]k", "move.goto_next_start",     "@block.outer", "Next block start" },
  { { "n", "x", "o" }, "]f", "move.goto_next_start",     "@function.outer", "Next function start" },
  { { "n", "x", "o" }, "]a", "move.goto_next_start",     "@parameter.outer", "Next parameter start" },
  { { "n", "x", "o" }, "]K", "move.goto_next_end",       "@block.outer", "Next block end" },
  { { "n", "x", "o" }, "]F", "move.goto_next_end",       "@function.outer", "Next function end" },
  { { "n", "x", "o" }, "]a", "move.goto_next_end",       "@parameter.outer", "Next parameter end" },
  { { "n", "x", "o" }, "[k", "move.goto_previous_start", "@block.outer", "Previous block start" },
  { { "n", "x", "o" }, "[f", "move.goto_previous_start", "@function.outer", "Previous function start" },
  { { "n", "x", "o" }, "[a", "move.goto_previous_start", "@parameter.outer", "Previous parameter start" },
  { { "n", "x", "o" }, "[K", "move.goto_previous_end",   "@block.outer", "Previous block end" },
  { { "n", "x", "o" }, "[F", "move.goto_previous_end",   "@function.outer", "Previous function end" },
  { { "n", "x", "o" }, "[A", "move.goto_previous_end",   "@parameter.outer", "Previous parameter end" },

  { "n", ">K", "swap.swap_next",     "@block.outer", "Swap next block" },
  { "n", ">F", "swap.swap_next",     "@function.outer", "Swap next function" },
  { "n", ">A", "swap.swap_next",     "@parameter.outer", "Swap next argument" },
  { "n", "<K", "swap.swap_previous", "@block.outer", "Swap previous block" },
  { "n", "<F", "swap.swap_previous", "@function.outer", "Swap previous function" },
  { "n", "<A", "swap.swap_previous", "@parameter.outer", "Swap previous argument" },
}
for _, spec in ipairs(textobjects) do
  local mode, key, path, query, desc = unpack(spec)
  local mod, method = path:match("^(%w+)%.(.+)$")
  vim.keymap.set(mode, key, function()
    require("nvim-treesitter-textobjects." .. mod)[method](query)
  end, { desc = desc })
end
