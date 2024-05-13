return {
  -- show keybindings
  {
    "folke/which-key.nvim",
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      wk.register({
        mode = { "n", "v" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>d"] = { name = "+debug" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>h"] = { name = "+githunk" },
        ["<leader>m"] = { name = "+harpoon" },
        ["<leader>n"] = { name = "+neotest" },
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>t"] = { name = "+term" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
        ["<leader><tab>"] = { name = "+tabs" },
      })

      -- local i = {
      --   [" "] = "Whitespace",
      --   ['"'] = 'Balanced "',
      --   ["'"] = "Balanced '",
      --   ["`"] = "Balanced `",
      --   ["("] = "Balanced (",
      --   [")"] = "Balanced ) including white-space",
      --   [">"] = "Balanced > including white-space",
      --   ["<lt>"] = "Balanced <",
      --   ["]"] = "Balanced ] including white-space",
      --   ["["] = "Balanced [",
      --   ["}"] = "Balanced } including white-space",
      --   ["{"] = "Balanced {",
      --   ["?"] = "User Prompt",
      --   _ = "Underscore",
      --   a = "Argument",
      --   b = "Balanced ), ], }",
      --   c = "Class",
      --   d = "Digit(s)",
      --   e = "Word in CamelCase & snake_case",
      --   f = "Function",
      --   g = "Entire file",
      --   o = "Block, conditional, loop",
      --   q = "Quote `, \", '",
      --   t = "Tag",
      --   u = "Use/call function & method",
      --   U = "Use/call without dot in name",
      -- }
      -- local a = vim.deepcopy(i)
      -- for k, v in pairs(a) do
      --   a[k] = v:gsub(" including.*", "")
      -- end
      --
      -- local ic = vim.deepcopy(i)
      -- local ac = vim.deepcopy(a)
      -- for key, name in pairs({ n = "Next", l = "Last" }) do
      --   i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
      --   a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
      -- end
      -- require("which-key").register({
      --   mode = { "o", "x" },
      --   i = i,
      --   a = a,
      -- })
    end,
  },
}
