local add = require("pack").add
local on_plugin_update = require("pack").on_plugin_update

local function install_list()
  local parsers = {
    "bash",
    "c",
    "cmake",
    "cpp",
    "diff",
    "dockerfile",
    "git_config",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "hcl",
    "html",
    "java",
    "javascript",
    "jsdoc",
    "json",
    "json5",
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
    "ron",
    "rst",
    "ruby",
    "rust",
    "scala",
    "scss",
    "terraform",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
  }

  local set = {}
  for _, parser in ipairs(parsers) do
    set[parser] = true
  end

  local site = vim.fn.stdpath("data")
  for _, path in ipairs(vim.api.nvim_get_runtime_file("parser/*", true)) do
    if not vim.startswith(path, site) then
      set[vim.fn.fnamemodify(path, ":t:r")] = true
    end
  end

  return vim.tbl_keys(set)
end

add({
  {
    src = "nvim-treesitter/nvim-treesitter",
    on_setup = function()
      local init = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/init.lua", false)[1]
      if init then
        vim.opt.runtimepath:prepend(vim.fn.fnamemodify(init, ":h:h:h") .. "/runtime")
      end

      require("nvim-treesitter").install(install_list()):wait(300000)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            vim.bo[args.buf].syntax = ""
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo[0][0].foldmethod = "expr"
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  },
  {
    src = "nvim-treesitter/nvim-treesitter-context",
    module_name = "treesitter-context",
    opts = {
      max_lines = 3,
      multiline_threshold = 1,
      min_window_height = 20,
    },
  },
  {
    src = "nvim-treesitter/nvim-treesitter-textobjects",
    opts = {
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = true,
      },
    },
    on_setup = function()
      local select = {
        ["ak"] = { query = "@block.outer", desc = "around block" },
        ["ik"] = { query = "@block.inner", desc = "inside block" },
        ["ac"] = { query = "@class.outer", desc = "around class" },
        ["ic"] = { query = "@class.inner", desc = "inside class" },
        ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
        ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
        ["af"] = { query = "@function.outer", desc = "around function" },
        ["if"] = { query = "@function.inner", desc = "inside function" },
        ["ao"] = { query = "@loop.outer", desc = "around loop" },
        ["io"] = { query = "@loop.inner", desc = "inside loop" },
        ["aa"] = { query = "@argument.outer", desc = "around argument" },
        ["ia"] = { query = "@argument.inner", desc = "inside argument" },
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
        end, { desc = "Select " .. opts.desc })
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
          vim.keymap.set("n", key, function()
            require("nvim-treesitter-textobjects.swap")[dir](opts.query)
          end, { desc = opts.desc })
        end
      end
    end,
  },
})

on_plugin_update("nvim-treesitter", function()
  require("nvim-treesitter").install(install_list()):wait(300000)
  require("nvim-treesitter").update():wait(300000)
end)
