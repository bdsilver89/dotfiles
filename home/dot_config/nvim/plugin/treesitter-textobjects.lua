vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
})

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
})

local select = {
  ["ak"] = { query = "@block.outer", desc = "Select around block" },
  ["ik"] = { query = "@block.inner", desc = "Select inside block" },
  ["ac"] = { query = "@class.outer", desc = "Select around class" },
  ["ic"] = { query = "@class.inner", desc = "Select inside class" },
  ["a?"] = { query = "@conditional.outer", desc = "Select around conditional" },
  ["i?"] = { query = "@conditional.inner", desc = "Select inside conditional" },
  ["af"] = { query = "@function.outer", desc = "Select around function" },
  ["if"] = { query = "@function.inner", desc = "Select inside function" },
  ["ao"] = { query = "@loop.outer", desc = "Select around loop" },
  ["io"] = { query = "@loop.inner", desc = "Select inside loop" },
  ["aa"] = { query = "@argument.outer", desc = "Select around argument" },
  ["ia"] = { query = "@argument.inner", desc = "Select inside argument" },
}

local move = {
  goto_next_start = {
    ["]k"] = { query = "@block.outer", desc = "Next block start" },
    ["]f"] = { query = "@function.outer", desc = "Next function start" },
    ["]a"] = { query = "@parameter.outer", desc = "Next parameter start" },
  },
  goto_next_end = {
    ["]K"] = { query = "@block.outer", desc = "Next block end" },
    ["]F"] = { query = "@function.outer", desc = "Next function end" },
    ["]A"] = { query = "@parameter.outer", desc = "Next parameter end" },
  },
  goto_previous_start = {
    ["[k"] = { query = "@block.outer", desc = "Previous block start" },
    ["[f"] = { query = "@function.outer", desc = "Previous function start" },
    ["[a"] = { query = "@parameter.outer", desc = "Previous parameter start" },
  },
  goto_previous_end = {
    ["[K"] = { query = "@block.outer", desc = "Previous block end" },
    ["[F"] = { query = "@function.outer", desc = "Previous function end" },
    ["[A"] = { query = "@parameter.outer", desc = "Previous parameter end" },
  },
}

local swap = {
  swap_next = {
    [">K"] = { query = "@block.outer", desc = "Swap next block" },
    [">F"] = { query = "@function.outer", desc = "Swap next function" },
    [">A"] = { query = "@parameter.outer", desc = "Swap next parameter" },
  },
  swap_previous = {
    ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
    ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
    ["<A"] = { query = "@parameter.outer", desc = "Swap previous parameter" },
  },
}

for keys, opts in pairs(select) do
  vim.keymap.set({ "x", "o" }, keys, function()
    require("nvim-treesitter-textobjects.select").select_textobject(opts.query, "textobjects")
  end, { desc = opts.desc })
end

for dir, mappings in pairs(move) do
  for key, opts in pairs(mappings) do
    vim.keymap.set({ "n", "x", "o" }, key, function()
      require("nvim-treesitter-textobjects.move")[dir](opts.query)
    end, { desc = opts.desc })
  end
end

for dir, mappings in pairs(swap) do
  for key, opts in pairs(mappings) do
    vim.keymap.set({ "n", "x", "o" }, key, function()
      require("nvim-treesitter-textobjects.swap")[dir](opts.query)
    end, { desc = opts.desc })
  end
end
