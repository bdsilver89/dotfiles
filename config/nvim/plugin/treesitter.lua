local ts_parsers = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "diff",
  "git_config",
  "gitcommit",
  "gitignore",
  "gitattributes",
  "go",
  "gomod",
  "gosum",
  "gowork",
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
  "markdown_inline",
  "markdown",
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

require("nvim-treesitter").install(ts_parsers)

vim.api.nvim_create_autocmd("FileType", {
  pattern = vim.iter(ts_parsers):map(vim.treesitter.language.get_filetypes):flatten():totable(),
  callback = function(ev)
    vim.treesitter.start(ev.buf)
  end,
})

-- Textobjects
local textobjects = {
  select = {
    select_textobject = {
      ["ak"] = "@block.outer",
      ["ik"] = "@block.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["a?"] = "@conditional.outer",
      ["i?"] = "@conditional.inner",
      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
    },
  },
  move = {
    goto_next_start = {
      ["]f"] = "@function.outer",
      ["]c"] = "@class.outer",
      ["]a"] = "@parameter.outer",
    },
    goto_next_end = {
      ["]F"] = "@function.outer",
      ["]C"] = "@class.outer",
      ["]A"] = "@parameter.outer",
    },
    goto_previous_start = {
      ["[f"] = "@function.outer",
      ["[c"] = "@class.outer",
      ["[a"] = "@parameter.outer",
    },
    goto_previous_end = {
      ["[F"] = "@function.outer",
      ["[C"] = "@class.outer",
      ["[A"] = "@parameter.outer",
    },
  },
  swap = {
    swap_next = {
      [">K"] = "@block.outer",
      [">F"] = "@function.outer",
      [">A"] = "@parameter.inner",
    },
    swap_previous = {
      ["<K"] = "@block.outer",
      ["<F"] = "@function.outer",
      ["<A"] = "@parameter.inner",
    },
  },
}

for kind, keys in pairs(textobjects) do
  for method, keymaps in pairs(keys) do
    for key, query in pairs(keymaps) do
      local obj = query:gsub("@", ""):gsub("%..*", "")
      obj = obj:sub(1, 1):upper() .. obj:sub(2)

      local first = key:sub(1, 1)
      local second = key:sub(2, 2)
      local dir = (first == "[") and "Prev" or "Next"
      local pos = (second == second:upper()) and "end" or "start"
      local desc = dir .. " " .. obj .. " " .. pos

      if not (vim.wo.diff and key:find("[cC]")) then
        vim.keymap.set({ "n", "x", "o" }, key, function()
          require("nvim-treesitter-textobjects." .. kind)[method](query, "textobjects")
        end, { silent = true, desc = desc })
      end
    end
  end
end
