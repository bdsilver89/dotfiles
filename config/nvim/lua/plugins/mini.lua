return {
  "echasnovski/mini.nvim",
  lazy = false,
  config = function()
    -- mini.bufremove

    -- mini extra
    require("mini.extra").setup()

    -- mini icons
    local icons = require("mini.icons")
    icons.setup()
    icons.mock_nvim_web_devicons()

    -- mini notify
    local notify = require("mini.notify")
    notify.setup()
    vim.notify = notify.make_notify()

    -- mini hipatterns
    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    })

    -- -- mini ai
    -- local ai = require("mini.ai")
    -- ai.setup({
    --   o = ai.gen_spec.treesitter({
    --     a = { "@block.outer", "@conditional.outer", "@loop.outer" },
    --     i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    --   }),
    --   f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    --   c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    --   l = ai.gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
    --   k = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
    --   a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@paramter.inner" }),
    --   ["?"] = ai.gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
    -- })

    -- mini clue
    local clue = require("mini.clue")
    clue.setup({
      triggers = {
        { mode = "n", keys = "<leader>" },
        { mode = "x", keys = "<leader>" },

        { mode = "i", keys = "<c-x>" },

        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },

        { mode = "n", keys = "s" },

        { mode = "n", keys = "<c-w>" },

        { mode = "n", keys = "z" },
        { mode = "x", keys = "z" },
      },
      clues = {
        clue.gen_clues.g(),
        clue.gen_clues.builtin_completion(),
        clue.gen_clues.windows(),
        clue.gen_clues.z(),
      },
    })

    -- mini.pairs
    require("mini.pairs").setup()

    -- mini surround
    require("mini.surround").setup()

    -- mini diff
    require("mini.diff").setup()

    -- mini bufremove
    vim.keymap.set("n", "<leader>bd", function()
      require("mini.bufremove").delete(0)
    end, { desc = "Remove buffer" })
    vim.keymap.set("n", "<leader>bD", function()
      require("mini.bufremove").delete(0, true)
    end, { desc = "Remove buffer" })

    -- mini statusline
    local statusline = require("mini.statusline")
    statusline.setup()
    statusline.section_location = function()
      return "%2l:%-2v"
    end

    -- mini indentscope
    local indentscope = require("mini.indentscope")
    indentscope.setup({
      draw = {
        animation = indentscope.gen_animation.none(),
      },
    })

    -- mini pick
    require("mini.pick").setup()

    vim.keymap.set("n", "<leader><space>", "<cmd>Pick files<cr>", { desc = "Pick files" })
    vim.keymap.set("n", "<leader>,", "<cmd>Pick buffers<cr>", { desc = "Pick buffers" })
    vim.keymap.set("n", "<leader>/", "<cmd>Pick grep_live<cr>", { desc = "Pick grep" })

    vim.keymap.set("n", "<leader>gb", "<cmd>Pick git_branches<cr>", { desc = "Pick git branches" })
    vim.keymap.set("n", "<leader>gc", "<cmd>Pick git_commits<cr>", { desc = "Pick git commits" })
    vim.keymap.set("n", "<leader>gh", "<cmd>Pick git_hunks<cr>", { desc = "Pick git hunks" })

    -- vim.keymap.set("n", "<leader>lr", "<cmd>Pick lsp scope='references'<cr>", { desc = "Pick lsp references" })
    -- vim.keymap.set("n", "<leader>ls", "<cmd>Pick lsp scope='document_symbols'<cr>", { desc = "Pick lsp document symbols" })
    -- vim.keymap.set("n", "<leader>lS", "<cmd>Pick lsp scope='workspace_symbols'<cr>", { desc = "Pick lsp workspace symbols" })
    -- vim.keymap.set("n", "<leader>ld", "<cmd>Pick lsp scope='definition'<cr>", { desc = "Pick lsp definition" })
    -- vim.keymap.set("n", "<leader>lD", "<cmd>Pick lsp scope='declaration'<cr>", { desc = "Pick lsp declaration" })
  end,
}
