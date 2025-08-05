return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = "VeryLazy",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "bash",
        "c",
        "cmake",
        "cpp",
        "css",
        "diff",
        "java",
        "javascript",
        "html",
        "lua",
        "luap",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    config = function(_, opts)
      local tsobj = require("nvim-treesitter-textobjects")
      tsobj.setup(opts)

      local tsobj_select = require("nvim-treesitter-textobjects.select")
      local assign = function(key, type)
        vim.keymap.set({ "x", "o" }, "a" .. key, function()
          tsobj_select.select_textobject("@" .. type .. ".outer", "textobjects")
        end)
        vim.keymap.set({ "x", "o" }, "i" .. key, function()
          tsobj_select.select_textobject("@" .. type .. ".inner", "textobjects")
        end)
      end

      assign("f", "function")
      assign("c", "class")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    opts = {},
  },
}
