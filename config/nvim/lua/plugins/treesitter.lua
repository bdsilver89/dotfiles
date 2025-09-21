local installed = nil

local function get_installed(force)
  if not installed or force then
    installed = {}
    for _, lang in ipairs(require("nvim-treesitter").get_installed("parsers")) do
      installed[lang] = lang
    end
  end
  return installed
end

local function have(ft)
  local lang = vim.treesitter.language.get_lang(ft)
  return lang and get_installed()[lang]
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = function()
      local ts = require("nvim-treesitter")
      if ts.get_installed then
        ts.update(nil, { summary = true })
      end
    end,
    lazy = vim.fn.argc(-1) == 0,
    event = { "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "diff",
        "html",
        "java",
        "javascript",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "ninja",
        "python",
        "printf",
        "query",
        "regex",
        "rust",
        "sql",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")

      if vim.fn.executable("tree-sitter") == 0 then
        vim.notify(
          "**nvim-treesitter-main** requires `tree-sitter` CLI executable to be installed",
          vim.log.levels.ERROR
        )
      end

      ts.setup(opts)

      local install = vim.tbl_filter(function(lang)
        return not have(lang)
      end, opts.ensure_installed or {})
      if #install > 0 then
        ts.install(install, { summary = true }):await(function()
          get_installed(true)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if have(ev.match) then
            pcall(vim.treesitter.start)

            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.opt_local.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {},
    keys = function()
      local moves = {
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
      }

      local ret = {}
      for method, keymaps in pairs(moves) do
        for key, query in pairs(keymaps) do
          local desc = query:gsub("@", ""):gsub("%..*", "")
          desc = desc:sub(1, 1):upper() .. desc:sub(2)
          desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
          desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
          ret[#ret + 1] = {
            key,
            function()
              -- don't use treesitter if in diff mode and the key is one of the c/C keys
              if vim.wo.diff and key:find("[cC]") then
                return vim.cmd("normal! " .. key)
              end
              require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
            end,
            desc = desc,
            mode = { "n", "x", "o" },
            silent = true,
          }
        end
      end

      return ret
    end,
  },
}
